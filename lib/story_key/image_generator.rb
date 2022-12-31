# frozen_string_literal: true
require 'ruby/openai'

class StoryKey::ImageGenerator < StoryKey::Base
  IMG_SIZE = '512x512'
  STYLE = 'simple cartoon'

  option :phrases

  def call
    return [] if openai_key.blank?
    image_urls
  end

  private

  def image_urls
    phrases.map do |phrase|
      response = dalle_client.images.generate(parameters: parameters(phrase))
      error = response.dig('error', 'message')
      error.present? ? error : response.dig('data', 0, 'url')
    end
  end

  def parameters(phrase)
    prompt = "#{phrase} in a #{STYLE} style"
    { prompt:, size: IMG_SIZE }
  end

  def openai_key
    @openai_key ||= ENV.fetch('OPENAI_KEY', nil)
  end

  def dalle_client
    @dalle_client ||= OpenAI::Client.new(access_token: openai_key)
  end
end
