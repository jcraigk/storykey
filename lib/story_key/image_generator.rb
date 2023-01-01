# frozen_string_literal: true
require 'open-uri'
require 'rmagick'
require 'ruby/openai'

class StoryKey::ImageGenerator < StoryKey::Base
  DALLE_SIZE = 512
  IMG_SIZE = 350
  STYLE = 'isometric art with white background'
  FONT_FILE = '../fonts/BarlowSemiCondensed-Regular.ttf'

  option :phrases

  def call
    return [] if openai_key.blank?
    image_urls
  end

  private

  def image_urls
    phrases.each_with_index.map do |phrase, idx|
      response = dalle_client.images.generate(parameters: parameters(phrase))
      error = response.dig('error', 'message')
      image_url = response.dig('data', 0, 'url')
      text = "#{idx + 1} of #{phrases.size}: #{phrase}"
      error.present? ? error : captioned_photo(image_url, text)
    end
  end

  def captioned_photo(image_url, phrase)
    local_image_path = local_image(image_url)
    comp = Magick::ImageList.new(local_image_path)
    comp.change_geometry!("#{IMG_SIZE}x#{IMG_SIZE}") do |cols, rows, img|
      img.resize!(cols, rows)
    end
    caption_bg = Magick::Image.new(IMG_SIZE, 28) { |m| m.background_color = '#ffffff' }
    comp = comp.composite(caption_bg, Magick::SouthGravity, 0, 0, Magick::OverCompositeOp)
    add_annotation(comp, phrase)
    comp.write(local_image_path)
    local_image_path
  end

  def add_annotation(comp, phrase)
    text = Magick::Draw.new
    comp.annotate(text, 0, 0, 0, 4, phrase) do
      text.gravity = Magick::SouthGravity
      text.pointsize = 16
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
