# frozen_string_literal: true
class Peartree::Encoder < Peartree::Base
  param :str
  option :format, optional: true

  BASE58_REGEX =
    /\A[123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz]+\Z/
  DEC_REGEX = /\A\d+\Z/
  HEX_REGEX = /\A[\da-f]+\Z/
  BIN_REGEX = /\A[0-1]+\Z/

  def call
    @str = str.strip
    @format ||= :hex

    validate_format!
    validate_length!

    Result.new(text, colorized)
  end

  private

  def text
    @text ||= colorized.no_color
  end

  def colorized
    @colorized ||= "#{version_str}#{newline}#{phrases.join(",\n")}"
  end

  def validate_length!
    return if bin_str.size <= MAX_INPUT_SIZE
    raise Peartree::InputTooLarge, "Max input size is #{MAX_INPUT_SIZE} bits"
  end

  def newline
    num_phrases == 1 ? ' ' : "\n"
  end

  def version_str
    "In #{Peartree::VERSION_SLUG.cyan} I saw"
  end

  def last_segment_size
    bin_segments.last.size
  end

  # Checksum uses any remaining bits in last segment
  # Plus 6 more bits in the last word
  # Before the final 4 tail bits
  def checksum_bitsize
    (BITS_PER_WORD * 2) - (tail_bitsize + FOOTER_BITSIZE)
  end

  def tail_bitsize
    (bin_str.size % BITS_PER_WORD)
  end

  def num_phrases
    raw_phrases.size
  end

  def phrases
    raw_phrases.each_with_index.map do |phrase, idx|
      parts = []
      if num_phrases > 1
        parts << "#{idx + 1}."
        parts << 'and' if idx == num_phrases - 1
      end
      # parts << phrase.no_color.indefinite_article
      parts << phrase
      parts.join(' ')
    end
  end

  # TODO
  def highlight(word)
    word
    # token = word.split.first[0..(ABBREV_SIZE - 1)]
    # tail = word[abbrev.size..]
    # matches = word.match(/\A(\[.+\])?([^\[\]]+)(\[.+\])?\Z/).to_a
    # "#{ary[0].magenta} #{ary[1]}".strip
  end

  def raw_phrases
    @raw_phrases ||= word_groups.map { |words| grammatical_phrase(words) }
  end

  def grammatical_phrase(words)
    str = ''
    grammar = GRAMMAR[words.size]
    grammar.each_with_index do |part_of_speech, idx|
      text = words[idx].text
      str += "#{text.indefinite_article} " if add_article?(grammar, part_of_speech, idx, words)
      str += "#{highlight(text)} "
    end
    str.strip
  end

  # Always prefix modified noun with article
  # 'an envious Einstein kill Vader' vs
  # 'envious Einstein kill Vader'
  def add_article?(grammar, part_of_speech, idx, words)
    noun_idx, force_countable =
      if part_of_speech == :adjective
        [idx + 1, true]
      elsif part_of_speech == :noun && grammar[idx - 1] != :adjective
        [idx, false]
      end
    force_countable || (noun_idx && words[noun_idx].countable)
  end

  def word_groups
    decimals.each_slice(GRAMMAR.keys.max).to_a.map do |dec_group|
      grammar = GRAMMAR[dec_group.size]
      dec_group.each_with_index.map do |decimal, idx|
        part_of_speech = grammar[idx]
        words = lex.words[part_of_speech]
        words[decimal].tap do
          # Shift words to prevent repeats
          (decimal..(words.size - 2)).each do |x|
            words[x] = words[x + 1]
          end
          lex.words[part_of_speech] = words[0..-2]
        end
      end
    end
  end

  def lex
    @lex ||= Peartree::Lexicon.new
  end

  def decimals
    bin_segments.map do |bin|
      Peartree::Coercer.call(bin, :bin, :dec).to_i
    end
  end

  def bin_segments
    idx = 0
    parts = []
    while idx < binary_str.size
      parts << binary_str[idx..(idx + BITS_PER_WORD - 1)]
      idx += BITS_PER_WORD
    end
    parts
  end

  def validate_format!
    raise_invalid_str unless str.match?(format_regex)
  end

  def format_regex
    case format.to_sym
    when :bin then BIN_REGEX
    when :dec then DEC_REGEX
    when :hex then HEX_REGEX
    when :base58 then BASE58_REGEX
    else raise_invalid_format
    end
  end

  def binary_str
    return @binary_str if @binary_str
    @binary_str ||= bin_str + checksum + footer
  end

  def footer
    tail_bitsize.to_s(2).rjust(FOOTER_BITSIZE, '0')
  end

  def bin_str
    @bin_str ||= Peartree::Coercer.call(str, format, :bin)
  end

  def checksum
    Digest::SHA256.hexdigest(bin_str)
                  .hex
                  .to_s(2)
                  .first(checksum_bitsize)
  end

  def raise_invalid_str
    raise Peartree::InvalidFormat, "Invalid input for format '#{format}'"
  end

  def raise_invalid_format
    raise Peartree::InvalidFormat,
          "Invalid format '#{format}'"
  end

  Result = Struct.new(:text, :colorized)
end
