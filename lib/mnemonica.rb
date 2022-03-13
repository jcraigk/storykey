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

  def self.encode(str)
    Encoder.new(str).call
  end
end

BITS_PER_WORD = 10
LEXICONS = %w[adjective noun verb verb].freeze
CONNECTING_WORDS = %w[in i saw and a an].freeze
