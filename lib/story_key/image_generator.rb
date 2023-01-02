# frozen_string_literal: true
require 'open-uri'
require 'rmagick'
require 'ruby/openai'

class StoryKey::ImageGenerator < StoryKey::Base
  BG_COLOR = '#ffffff'
  CAPTION_FONT_SIZE = 15
  CAPTION_HEIGHT = 30
  DALLE_SIZE = 512
  FONT_PATH = File.expand_path('assets/BarlowSemiCondensed-Regular.ttf')
  ERROR_IMAGE = File.expand_path('assets/error.png')
  OUTPUT_PATH = File.expand_path('tmp/story-key.png')
  FOOTER_FONT_SIZE = 17
  FOOTER_HEIGHT = 30
  HEADER_FONT_SIZE = 17
  PANEL_SIZE = 350
  PADDING = 10
  STYLE = 'isometric art with white background'

  option :seed
  option :phrases

  def call
    return if openai_key.blank?
    composite_image
  end

  private

  def comp_width
    num_cols = phrases.size > 1 ? 2 : 1
    (PANEL_SIZE * num_cols) + (PADDING * (num_cols + 1))
  end

  def comp_height
    num_rows = (phrases.size.to_f / 2).ceil
    (PANEL_SIZE * num_rows) + (PADDING * (num_rows + 1)) + header_height + FOOTER_HEIGHT
  end

  def header_height
    ((multiline_seed.split("\n").size + 1) * (HEADER_FONT_SIZE * 1.2)).ceil
  end

  def multiline_seed
    ary = seed.split
    ary.each_slice(8)
       .to_a
       .map { |a| a.join(' ') }
       .join("\n")
  end

  def composite_image
    comp = image_background
    comp = add_header(comp)
    comp = add_panels(comp)
    comp = add_footer(comp)
    comp.write(OUTPUT_PATH)
    delete_source_images
    OUTPUT_PATH
  end

  def delete_source_images
    image_paths.each { |path| FileUtils.rm_f(path) }
  end

  def add_panels(comp)
    image_paths.each_slice(2).to_a.each_with_index do |row, row_idx|
      row.each_with_index do |image_path, col_idx|
        comp = add_panel(comp, image_path, row.size, row_idx, col_idx)
      end
    end
    comp
  end

  def add_panel(comp, image_path, row_size, row_idx, col_idx)
    y = header_height + (PANEL_SIZE * row_idx) + (PADDING * (row_idx + 2))
    if row_size == 1 # Center the last image if it has no pair
      gravity = Magick::NorthGravity
      x = 0
    else
      gravity = Magick::NorthWestGravity
      x = (PANEL_SIZE * col_idx) + (PADDING * (col_idx + 2))
    end
    img = Magick::ImageList.new(image_path)
    comp.composite(img, gravity, x, y, Magick::OverCompositeOp)
  end

  def image_background
    Magick::Image.new(comp_width, comp_height) do |m|
      m.background_color = BG_COLOR
    end
  end

  def image_paths
    @image_paths ||= phrases.each_with_index.map do |phrase, idx|
      response = dalle_client.images.generate(parameters: parameters(phrase))
      error = response.dig('error', 'message')
      image_url = response.dig('data', 0, 'url')
      text = "#{idx + 1}. #{phrase}"
      local_image_path(image_url, text, error.present?)
    end
  end

  def local_image_path(image_url, phrase, error)
    source_path, destination_path = panel_paths(error, image_url)
    comp = Magick::ImageList.new(source_path)
    comp.change_geometry!("#{PANEL_SIZE}x#{PANEL_SIZE}") do |cols, rows, img|
      img.resize!(cols, rows)
    end
    caption_bg = Magick::Image.new(PANEL_SIZE, CAPTION_HEIGHT) { |m| m.background_color = BG_COLOR }
    comp = comp.composite(caption_bg, Magick::SouthGravity, 0, 0, Magick::OverCompositeOp)
    add_caption(comp, phrase)
    comp.write(destination_path)
    destination_path
  end

  def panel_paths(error, image_url)
    if error
      [ERROR_IMAGE, "#{SecureRandom.hex(10)}.png"]
    else
      local = local_image(image_url)
      Array.new(2) { local }
    end
  end

  def add_header(comp)
    draw = Magick::Draw.new
    comp.annotate(draw, 0, 0, 0, 5, multiline_seed) do
      draw.gravity = Magick::NorthGravity
      draw.pointsize = HEADER_FONT_SIZE
      draw.fill = '#000000'
      draw.font = FONT_PATH
      comp.format = 'png'
    end
    comp
  end

  def add_footer(comp)
    text = "Made with StoryKey - #{StoryKey::GITHUB_URL}"
    draw = Magick::Draw.new
    comp.annotate(draw, 0, 0, 0, 10, text) do
      draw.gravity = Magick::SouthGravity
      draw.pointsize = FOOTER_FONT_SIZE
      draw.fill = '#000000'
      draw.font = FONT_PATH
      comp.format = 'png'
    end
    comp
  end

  def add_caption(comp, text)
    draw = Magick::Draw.new
    offset = ((CAPTION_HEIGHT - CAPTION_FONT_SIZE).to_f / 2).ceil
    comp.annotate(draw, 0, 0, 0, offset, text) do
      draw.gravity = Magick::SouthGravity
      draw.pointsize = CAPTION_FONT_SIZE
      draw.fill = '#000000'
      draw.font = FONT_PATH
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
