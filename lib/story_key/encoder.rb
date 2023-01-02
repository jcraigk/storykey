# frozen_string_literal: true
class StoryKey::Encoder < StoryKey::Base
  option :bitsize, default: -> {}
  option :format, default: -> {}
  option :key

  BASE58_REGEX = /\A[1-9A-Za-z]+\Z/
  DEC_REGEX = /\A\d+\Z/
  HEX_REGEX = /\A[\da-f]+\Z/
  BIN_REGEX = /\A[0-1]+\Z/
  COLORS = {
    adjective: 36,
    noun: 33,
    preposition: nil,
    slug: 31,
    verb: 35
  }.freeze

  def call
    @key = key.strip
    @format ||= StoryKey::FORMATS.first

    validate_format!
    validate_length!

    StoryKey::Story.new(phrases: text_phrases, text:, humanized:, tokenized:)
  end

  private

  def text_phrases
    raw_phrases.map { |str| remove_markup(str) }
  end

  def tokenized
    @tokenized ||= "#{StoryKey::VERSION_SLUG.downcase} #{token_str}"
  end

  def token_str
    entry_groups.flatten.map(&:token).join(' ')
  end

  def text
    @text ||= remove_markup(humanized).squish
  end

  def humanized
    @humanized ||= "#{version_str}#{newline}#{phrases.join(",\n")}."
  end

  def validate_length!
    return if bin_str.size <= StoryKey::MAX_BITSIZE
    raise StoryKey::KeyTooLarge, "Max input size is #{StoryKey::MAX_BITSIZE} bits"
  end

  def newline
    num_phrases == 1 ? ' ' : "\n"
  end

  def version_str
    "In #{colorize(StoryKey::VERSION_SLUG, COLORS[:slug])} I saw"
  end

  def last_segment_size
    bin_segments.last.size
  end

  # Checksum uses any remaining bits in last segment
  # Plus 6 more bits in the last word
  # Before the final 4 tail bits
  def checksum_bitsize
    (StoryKey::BITS_PER_ENTRY * 2) - (tail_bitsize + StoryKey::FOOTER_BITSIZE)
  end

  def tail_bitsize
    (bin_str.size % StoryKey::BITS_PER_ENTRY)
  end

  def num_phrases
    raw_phrases.size
  end

  def phrases
    raw_phrases.each_with_index.map do |phrase, idx|
      [].tap do |ary|
        if num_phrases > 1
          ary << "#{idx + 1}."
          ary << 'and' if idx == num_phrases - 1
        end
        ary << phrase
      end.join(' ')
    end
  end

  def highlight(entry)
    ary =
      if entry.preposition
        [entry.text.gsub(/\s#{entry.preposition}\Z/, ''), entry.preposition]
      else
        [entry.text]
      end
    main = colorize(ary[0], COLORS[entry.part_of_speech])
    prep = colorize(ary[1], COLORS[:preposition])
    "#{main} #{prep}".strip
  end

  def colorize(text, num)
    return text if text.blank? || num.blank?
    "\e[#{num}m#{text}\e[0m"
  end

  def raw_phrases
    @raw_phrases ||= entry_groups.map { |entries| grammatical_phrase(entries) }
  end

  def grammatical_phrase(entries)
    str = ''
    grammar = StoryKey::GRAMMAR[entries.size]
    grammar.each_with_index do |part_of_speech, idx|
      next if (entry = entries[idx]).blank?
      if add_article?(grammar, part_of_speech, idx, entries)
        str += "#{colorize(entry.text.indefinite_article, COLORS[:preposition])} "
      end
      str += "#{highlight(entry)} "
    end
    str.strip
  end

  # Always prefix modified noun with article
  # 'an envious Einstein kill Vader' vs
  # 'envious Einstein kill Vader'
  def add_article?(grammar, part_of_speech, idx, entries)
    noun_idx, force_countable =
      if part_of_speech == :adjective
        [idx + 1, true]
      elsif part_of_speech == :noun && grammar[idx - 1] != :adjective
        [idx, false]
      end
    force_countable || (noun_idx && entries[noun_idx].countable)
  end

  def entry_groups
    @entry_groups ||=
      decimals.each_slice(StoryKey::GRAMMAR.keys.max).to_a.map do |dec_group|
        dec_group.each_with_index.map do |decimal, idx|
          entry_from_decimal(StoryKey::GRAMMAR[dec_group.size], decimal, idx)
        end
      end
  end

  def entry_from_decimal(grammar, decimal, idx)
    part_of_speech = grammar[idx]
    entries = lex.entries[part_of_speech]
    entries[decimal].tap do
      # Shift entries to prevent repeats
      lex.entries[part_of_speech] =
        if decimal.zero?
          entries[1..]
        else
          entries[..(decimal - 1)] + entries[(decimal + 1)..]
        end
    end
  end

  def lex
    @lex ||= StoryKey::Lexicon.new
  end

  def decimals
    bin_segments.map do |str|
      StoryKey::Coercer.call(str:, from: :bin, to: :dec).to_i
    end
  end

  def bin_segments
    idx = 0
    parts = []
    while idx < binary_str.size
      parts << binary_str[idx..(idx + StoryKey::BITS_PER_ENTRY - 1)]
      idx += StoryKey::BITS_PER_ENTRY
    end
    parts
  end

  def validate_format!
    raise_invalid_key unless key.match?(format_regex)
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
    @binary_str ||= bin_str + checksum + footer
  end

  def footer
    tail_bitsize.to_s(2).rjust(StoryKey::FOOTER_BITSIZE, '0')
  end

  def bin_str
    @bin_str ||= StoryKey::Coercer.call(str: key, bitsize:, from: format, to: :bin)
  end

  def checksum
    Digest::SHA256.hexdigest(bin_str)
                  .hex
                  .to_s(2)
                  .first(checksum_bitsize)
  end

  def raise_invalid_key
    raise StoryKey::InvalidFormat, "Invalid input for format '#{format}'"
  end

  def raise_invalid_format
    raise StoryKey::InvalidFormat, "Invalid format '#{format}'"
  end

  def remove_markup(str)
    str.gsub(/\e\[\d+m/, '').gsub(/\n\d+\./, '').delete("\n")
  end
end
