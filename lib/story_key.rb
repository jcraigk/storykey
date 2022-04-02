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
  class Error < StandardError; end
  class InvalidFormat < Error; end
  class InvalidVersion < Error; end
  class InvalidWord < Error; end
  class InvalidChecksum < Error; end
  class KeyTooLarge < Error; end

  Entry = Struct.new \
    :raw, :token, :text, :countable, :preposition, :part_of_speech,
    keyword_init: true
  Story = Struct.new \
    :text, :humanized, :tokenized, keyword_init: true
end

BITS_PER_WORD = 10
GRAMMAR = {
  4 => %i[adjective noun verb noun],
  3 => %i[noun verb noun],
  2 => %i[adjective noun],
  1 => %i[noun]
}.freeze
DEFAULT_BITSIZE = 256
FOOTER_BITSIZE = 4 # BITS_PER_WORD <= 2^FOOTER_BITSIZE
MAX_KEY_SIZE = 512
PREPOSITIONS = %w[in i saw and a an].freeze

loader.eager_load
