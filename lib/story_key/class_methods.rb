# frozen_string_literal: true

module StoryKey::ClassMethods
  def encode(...)
    StoryKey::Encoder.call(...)
  end

  def decode(...)
    StoryKey::Decoder.call(...)
  end

  def generate(bitsize: DEFAULT_BITSIZE)
    key = StoryKey::Generator.call(bitsize:)
    key = StoryKey::Coercer.call(str: key, bitsize:, from: :bin, to: :base58)
    encoded = encode(key:, bitsize:)
    raise 'An error occurred!' if key != decode(story: encoded.story)
    puts [
      "\e[44mKey:\e[0m",
      key,
      "\e[44mStory:\e[0m",
      encoded.colorized
    ].join("\n")
  end
end
