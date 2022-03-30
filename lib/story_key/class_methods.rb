# frozen_string_literal: true
module StoryKey::ClassMethods
  def encode(...)
    StoryKey::Encoder.call(...)
  end

  def decode(...)
    StoryKey::Decoder.call(...)
  end

  def recover
    StoryKey::Recover.call
  end

  def generate(bitsize: DEFAULT_BITSIZE)
    key = StoryKey::Generator.call(bitsize:)
    encoded = encode(key:, bitsize:)
    raise 'An error occurred!' if key != decode(story: encoded.story)
    [key, encoded]
  end
end

module StoryKey
  extend StoryKey::ClassMethods
end
