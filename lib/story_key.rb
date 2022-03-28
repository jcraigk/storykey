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

module StoryKey; end

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

require_relative 'story_key/base'
require_relative 'story_key/class_methods'
require_relative 'story_key/cli'
require_relative 'story_key/cli/recover'
require_relative 'story_key/coercer'
require_relative 'story_key/decoder'
require_relative 'story_key/encoder'
require_relative 'story_key/errors'
require_relative 'story_key/generator'
require_relative 'story_key/lexicon'
require_relative 'story_key/tokenizer'
require_relative 'story_key/version'
