# frozen_string_literal: true
require 'active_support/core_ext/enumerable'
require 'active_support/core_ext/object/inclusion'
require 'active_support/core_ext/string/access'
require 'active_support/core_ext/string/inflections'
require 'base58'
require 'digest'
require 'dry-initializer'
require 'indefinite_article'
require 'pry'
require 'remedy'
require 'thor'
require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem
loader.setup

module StoryKey
  BITS_PER_ENTRY = 10
  DEFAULT_BITSIZE = 256
  DEFAULT_FORMAT = :base58
  FOOTER_BITSIZE = 4 # StoryKey::BITS_PER_ENTRY <= 2^StoryKey::FOOTER_BITSIZE
  GRAMMAR = {
    4 => %i[adjective noun verb noun],
    3 => %i[noun verb noun],
    2 => %i[adjective noun],
    1 => %i[noun]
  }.freeze
  MAX_BITSIZE = 512
  PREPOSITIONS = %w[in i saw and a an].freeze

  Entry = Struct.new \
    :raw, :token, :text, :countable, :preposition, :part_of_speech, keyword_init: true
  Story = Struct.new(:text, :humanized, :tokenized, keyword_init: true)

  class Error < StandardError; end
  class InvalidFormat < Error; end
  class InvalidVersion < Error; end
  class InvalidWord < Error; end
  class InvalidChecksum < Error; end
  class KeyTooLarge < Error; end
end

loader.eager_load
