# frozen_string_literal: true
require 'active_support/core_ext/enumerable'
require 'active_support/core_ext/object/inclusion'
require 'active_support/core_ext/string/access'
require 'active_support/core_ext/string/inflections'
require 'base58'
require 'digest'
require 'dry-initializer'
require 'humanize'
require 'indefinite_article'
require 'pry'

require_relative 'story_key/base'
require_relative 'story_key/coercer'
require_relative 'story_key/decoder'
require_relative 'story_key/encoder'
require_relative 'story_key/generator'
require_relative 'story_key/lexicon'
require_relative 'story_key/tokenizer'
require_relative 'story_key/version'

module StoryKey
  class Error < StandardError; end
  class InvalidFormat < Error; end
  class InvalidVersion < Error; end
  class InvalidWord < Error; end
  class InvalidChecksum < Error; end
  class KeyTooLarge < Error; end

  def self.encode(...)
    Encoder.call(...)
  end

  def self.decode(...)
    Decoder.call(...)
  end

  def self.generate(bitsize: DEFAULT_BITSIZE)
    1000.times do
      key = StoryKey::Generator.call(bitsize:)
      format = :bin
      encoded = encode(key:, bitsize:, format:)
      raise 'An error occurred!' if key != decode(story: encoded.story, format:)
      key = Coercer.call(str: key, bitsize:, input: format, output: :base58)
      puts [
        "\e[44mKey:\e[0m",
        key,
        "\e[44mStory:\e[0m",
        encoded.colorized
      ].join("\n")
    end
  end
end

BITS_PER_WORD = 10
PREPOSITIONS = %w[in i saw and a an].freeze
GRAMMAR = {
  4 => %i[adjective noun verb noun],
  3 => %i[noun verb noun],
  2 => %i[adjective noun],
  1 => %i[noun]
}.freeze
LEXICONS = %i[adjective noun verb].freeze
MAX_INPUT_SIZE = 512
DEFAULT_BITSIZE = 256
FOOTER_BITSIZE = 4 # BITS_PER_WORD <= 2^FOOTER_BITSIZE
