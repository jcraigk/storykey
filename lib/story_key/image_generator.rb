# frozen_string_literal: true
require 'open-uri'
require 'rmagick'
require 'ruby/openai'

class StoryKey::ImageGenerator < StoryKey::Base
  BG_COLOR = '#ffffff'
  CAPTION_FONT_SIZE = 15
  DALLE_SIZE = 512
  FONT_FILE = '../fonts/BarlowSemiCondensed-Regular.ttf'
  FOOTER_FONT_SIZE = 18
  FOOTER_HEIGHT = 30
  IMG_SIZE = 350
  PADDING = 10
  STYLE = 'isometric art with white background'

  option :phrases

  def call
    return if openai_key.blank?
    composite_image
  end

  private

  def comp_width
    num_cols = phrases.size > 1 ? 2 : 1
    (IMG_SIZE * num_cols) + (PADDING * (num_cols + 1))
  end

  def comp_height
    num_rows = (phrases.size.to_f / 2).ceil
    (IMG_SIZE * num_rows) + (PADDING * (num_rows + 1)) + FOOTER_HEIGHT
  end

  def composite_image
    comp = Magick::Image.new(comp_width, comp_height) do |m|
      m.background_color = BG_COLOR
    end
    image_paths.each_slice(2).to_a.each_with_index do |row, row_idx|
      row.each_with_index do |image_path, col_idx|
        next if image_path == 'Error' # TODO: Add a caption only

        y = (IMG_SIZE * row_idx) + (PADDING * (row_idx + 2))
        if row.size == 1 # Center the last image if it has no pair
          gravity = Magick::NorthGravity
          x = 0
        else
          gravity = Magick::NorthWestGravity
          x = (IMG_SIZE * col_idx) + (PADDING * (col_idx + 2))
        end
        img = Magick::ImageList.new(image_path)
        comp = comp.composite(img, gravity, x, y, Magick::OverCompositeOp)
      end
    end
    comp = add_annotation(comp, "Made with StoryKey - #{StoryKey::GITHUB_URL}", FOOTER_FONT_SIZE)
    image_paths.each { |path| FileUtils.rm_f(path) }
    path = File.expand_path('tmp/story_key.png')
    comp.write(path)
    path
  end

  def image_paths
    phrases.each_with_index.map do |phrase, idx|
      response = dalle_client.images.generate(parameters: parameters(phrase))
      error = response.dig('error', 'message')
      image_url = response.dig('data', 0, 'url')
      text = "#{idx + 1}. #{phrase}"
      error.present? ? 'Error' : local_image_path(image_url, text)
    end
  end

  def local_image_path(image_url, phrase)
    local_image_path = local_image(image_url)
    comp = Magick::ImageList.new(local_image_path)
    comp.change_geometry!("#{IMG_SIZE}x#{IMG_SIZE}") do |cols, rows, img|
      img.resize!(cols, rows)
    end
    caption_bg = Magick::Image.new(IMG_SIZE, FOOTER_HEIGHT) { |m| m.background_color = BG_COLOR }
    comp = comp.composite(caption_bg, Magick::SouthGravity, 0, 0, Magick::OverCompositeOp)
    add_annotation(comp, phrase, CAPTION_FONT_SIZE)
    comp.write(local_image_path)
    local_image_path
  end

  def add_annotation(comp, phrase, font_size)
    text = Magick::Draw.new
    offset = ((FOOTER_HEIGHT - font_size).to_f / 2).ceil
    comp.annotate(text, 0, 0, 0, offset, phrase) do
      text.gravity = Magick::SouthGravity
      text.pointsize = font_size
      text.fill = '#000000'
      text.font = File.expand_path('fonts/BarlowSemiCondensed-Regular.ttf')
      comp.format = 'png'
    end
    comp
  end

  def local_image(image_url)
    filename = image_url.split('?').first.split('/').last
    path = File.expand_path("tmp/#{filename}")
    File.open(path, 'wb') do |file|
      file << URI.parse(image_url).open.read
    end
    path
  end

  def parameters(phrase)
    prompt = "#{phrase}, #{STYLE}"
    { prompt:, size: "#{DALLE_SIZE}x#{DALLE_SIZE}" }
  end

  def openai_key
    @openai_key ||= ENV.fetch('OPENAI_KEY', nil)
  end

  def dalle_client
    @dalle_client ||= OpenAI::Client.new(access_token: openai_key)
  end
end
