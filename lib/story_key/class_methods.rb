# frozen_string_literal: true
module StoryKey::ClassMethods
  def encode(...)
    StoryKey::Encoder.call(...)
  end

  def decode(...)
    StoryKey::Decoder.call(...)
  end

  def recover
    StoryKey::Console::Recover.call
  end

  def generate(bitsize: StoryKey::DEFAULT_BITSIZE)
    key = StoryKey::KeyGenerator.call(bitsize:)
    encoded = encode(key:, bitsize:)
    raise 'An error occurred!' if key != decode(story: encoded.text)
    [key, encoded]
  end
end

module StoryKey
  extend StoryKey::ClassMethods
end
