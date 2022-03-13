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

# class Mnemonica
#   includ Mnemonica
# end
