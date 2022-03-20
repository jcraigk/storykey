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

require_relative 'peartree/base'
require_relative 'peartree/string'
require_relative 'peartree/coercer'
require_relative 'peartree/decoder'
require_relative 'peartree/encoder'
require_relative 'peartree/lexicon'
require_relative 'peartree/version'
require_relative 'peartree/generator'

module Peartree
  class Error < StandardError; end
  class InvalidFormat < Error; end
  class InvalidVersion < Error; end
  class InvalidWord < Error; end
  class InvalidChecksum < Error; end
  class InputTooLarge < Error; end

  def self.encode(str, format: nil)
    Encoder.call(str, format:)
  end

  def self.decode(str, format: nil)
    Decoder.call(str, format:)
  end

  def self.generate(bitsize: DEFAULT_BITSIZE)
    bin = Peartree::Generator.call(bitsize)
    phrase = encode(bin, format: :bin)
    raise 'An error occurred!' if bin != decode(phrase.text, format: :bin)
    key = Coercer.call(bin, :bin, :base58)
    puts [
      'Key:'.bg_blue,
      key,
      'Phrase:'.bg_blue,
      phrase.colorized
    ].join("\n")
  end
end

BITS_PER_WORD = 10
LINKING_WORDS = %w[in i saw and a an].freeze
GRAMMAR = %i[adjective noun verb adjective noun].freeze
LEXICONS = %i[adjective noun verb].freeze
NUM_PAD_WORDS = 26
MAX_INPUT_SIZE = 512
DEFAULT_BITSIZE = 256
ABBREV_SIZE = 13 # TODO: get this down to 4 or 5
FOOTER_BITSIZE = 4 # BITS_PER_WORD <= 2^FOOTER_BITSIZE
