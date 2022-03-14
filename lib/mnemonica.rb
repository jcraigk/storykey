# frozen_string_literal: true
require 'dry-initializer'
require 'active_support/all' # TODO: we don't need /all
require 'pry'
require 'indefinite_article'

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

  def self.encode(str, format: nil)
    Encoder.new(str, format:).call
  end

  def self.decode(str, format: nil)
    Decoder.new(str, format:).call
  end
end

BITS_PER_WORD = 10
LEXICONS = %i[adjective noun verb verb].freeze
CONNECTING_WORDS = %w[in i saw and a an at].freeze
