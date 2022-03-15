# frozen_string_literal: true
require 'active_support/core_ext/enumerable'
require 'active_support/core_ext/object/inclusion'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/string/access'
require 'digest'
require 'dry-initializer'
require 'humanize'
require 'indefinite_article'
require 'pry'

require_relative 'mnemonica/decoder'
require_relative 'mnemonica/encoder'
require_relative 'mnemonica/lexicon'
require_relative 'mnemonica/version'

module Mnemonica
  class Error < StandardError; end
  class InvalidFormat < Error; end
  class InvalidVersion < Error; end
  class InvalidWord < Error; end
  class InvalidTime < Error; end
  class InvalidChecksum < Error; end
  class InputTooLarge < Error; end

  def self.encode(str, format: nil)
    Encoder.new(str, format:).call
  end

  def self.decode(str, format: nil)
    Decoder.new(str, format:).call
  end
end

BITS_PER_WORD = 10
CONNECTING_WORDS = %w[
  in i saw and a an at
  one two three four five six seven eight nine ten
  eleven twelve thirteen fourteen fifteen
].freeze
GRAMMAR = %i[adjective noun verb adjective noun].freeze
LEXICONS = %i[adjective noun verb].freeze
NUM_PAD_WORDS = 26
MAX_INPUT_BITS = 512
