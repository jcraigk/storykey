# frozen_string_literal: true
class Mnemonica::Encoder
  extend Dry::Initializer
  extend ::ActiveSupport::Concern

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
      if (idx % LEXICONS.size).zero?
        num += 1
        sentences << str.strip unless num == 1
        str = ''
      end
      str += "#{word} "
    end.map(&:humanize)
  end

  def words
    idx = -1
    decimals.map do |dec|
      idx += 1
      idx = idx % LEXICONS.size
      lexicon_words[LEXICONS[idx]][dec]
    end
  end

  def lexicon_words
    @lexicon_words ||= LEXICONS.index_with do |lexicon|
      File.readlines("lexicons/#{lexicon}s.txt").map(&:strip)
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
      parts << bin_str[idx..(idx + BITS_PER_WORD - 1)]
      idx += BITS_PER_WORD
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
