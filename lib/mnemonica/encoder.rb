# frozen_string_literal: true

class Mnemonica::Encoder
  extend Dry::Initializer
  extend ::ActiveSupport::Concern

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
  LENGTH = 10
  WORD_TYPES = %w[adjective noun verb adverb].freeze

  param :str

  def call
    ensure_format!
    sentences
  end

  private

  def sentences
    num = 0
    str = ''
    words.each_with_index.with_object([]) do |(word, idx), sentences|
      if (idx % WORD_TYPES.size).zero?
        num += 1
        sentences << str.strip unless num == 1
        str = ''
      end
      str += "#{word} "
    end.map(&:humanize)
  end

  def words
    word_idx = 0
    decimals.map do |dec|
      word_type = WORD_TYPES[word_idx]
      word_idx += 1
      word_idx = word_idx % WORD_TYPES.size # TODO: shorten this
      lexicon_words[word_type][dec]
    end
  end

  def lexicon_words
    @lexicon_words ||= WORD_TYPES.index_with do |type|
      File.readlines("lexicons/#{type}s.txt").map(&:strip)
    end
  end

  def decimals
    binary_parts.map { |b| bin_to_dec(b) }
  end

  def bin_to_dec(binary)
    binary.reverse.chars.map.with_index do |digit, index|
      digit.to_i * (2**index)
    end.sum
  end

  def binary_parts
    idx = 0
    parts = []
    while idx < bin_str.size
      parts << bin_str[idx..(idx + LENGTH - 1)]
      idx += LENGTH
    end
    parts
  end

  def bin_str
    binary? ? str : hex_as_bin
  end

  def ensure_format!
    return if hexidecimal? || binary?
    raise(Mnemonica::InvalidFormat, 'Input must be in hexidecimal or binary form')
  end

  def hex_as_bin
    str.chars.map { |x| HEX_TO_BIN[x] }.join
  end

  def hexidecimal?
    str.match?(/\A\h+\Z/)
  end

  def binary?
    str.match?(/\A[0-1]+\Z/)
  end
end
