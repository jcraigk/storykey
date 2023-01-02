# frozen_string_literal: true
class StoryKey::KeyGenerator < StoryKey::Base
  option :bitsize, default: -> {}
  option :format, default: -> {}

  def call
    @bitsize ||= StoryKey::DEFAULT_BITSIZE
    @format ||= StoryKey::FORMATS.first

    formatted_str
  end

  private

  def formatted_str
    StoryKey::Coercer.call(str:, bitsize:, from: :bin, to: format)
  end

  def str
    "1#{random_bin}"[0, bitsize]
  end

  def random_bin
    SecureRandom.hex(bitsize / 8).hex.to_s(2).rjust(bitsize, '0')
  end
end
