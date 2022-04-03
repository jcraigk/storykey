# frozen_string_literal: true
class StoryKey::Generator < StoryKey::Base
  option :bitsize, default: -> {}
  option :format, default: -> {}

  def call
    @bitsize ||= StoryKey::DEFAULT_BITSIZE
    @format ||= StoryKey::DEFAULT_FORMAT

    formatted_str
  end

  private

  def formatted_str
    StoryKey::Coercer.call(str: random_bin, bitsize:, from: :bin, to: format)
  end

  def random_bin
    SecureRandom.hex(bitsize / 8).hex.to_s(2).rjust(bitsize, '0')
  end
end
