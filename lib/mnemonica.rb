# frozen_string_literal: true
require 'dry-initializer'
require 'active_support/all' # TODO: we don't need /all
require 'pry'

require_relative 'mnemonica/version'
require_relative 'mnemonica/encoder'

module Mnemonica
  class Error < StandardError; end
  class InvalidFormat < Error; end

  def self.encode(str)
    Encoder.new(str).call
  end
end

HEX_TO_BIN = {
  '0' => '0',
  '1' => '1',
  '2' => '10',
  '3' => '11',
  '4' => '100',
  '5' => '101',
  '6' => '110',
  '7' => '111',
  '8' => '1000',
  '9' => '1001',
  'a' => '1010',
  'b' => '1011',
  'c' => '1100',
  'd' => '1101',
  'e' => '1110',
  'f' => '1111'
}.freeze
BITS_PER_WORD = 10
LEXICONS = %w[adjective noun verb adverb].freeze
