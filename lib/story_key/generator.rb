# frozen_string_literal: true
class StoryKey::Generator < StoryKey::Base
  option :bitsize, default: -> {}
  option :format, default: -> {}

  def call
    @bitsize ||= DEFAULT_BITSIZE
    @format ||= :base58

    formatted_str
  end

  private

  def formatted_str
    StoryKey::Coercer.call(str: random_bin, bitsize:, from: :bin, to: format)
  end

  def random_bin
    SecureRandom.random_bytes(32).unpack1('H*').hex.to_s(2).first(bitsize)
  end
end
