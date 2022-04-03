# frozen_string_literal: true
class StoryKey::Decoder < StoryKey::Base
  option :story
  option :format, default: -> {}

  def call
    @story = story.strip
    @format ||= StoryKey::DEFAULT_FORMAT

    validate_version!
    validate_checksum!

    decoded_str
  end

  private

  def decoded_str
    StoryKey::Coercer.call(str: bin_str, from: :bin, to: format)
  end

  def binary_str
    @binary_str ||=
      decimals.map do |dec|
        dec.to_s(2).rjust(StoryKey::BITS_PER_ENTRY, '0')
      end.join
  end

  def bin_str
    @bin_str ||= binary_str[0..(checksum_start_idx - 1)]
  end

  def validate_checksum!
    return if computed_checksum == embedded_checksum
    raise StoryKey::InvalidChecksum, 'Checksum mismatch!'
  end

  def validate_version!
    return if version_word.casecmp(StoryKey::VERSION_SLUG).zero?
    raise StoryKey::InvalidVersion, version_error_msg
  end

  def version_error_msg
    <<~TEXT
      Missing or invalid version slug! Given '#{version_word.titleize}' but expected '#{StoryKey::VERSION_SLUG}'.
    TEXT
  end

  def tail_bitsize
    StoryKey::Coercer.call(
      str: footer,
      from: :bin,
      to: :dec
    ).to_i
  end

  def embedded_checksum
    binary_str[checksum_start_idx..-(StoryKey::FOOTER_BITSIZE + 1)]
  end

  def checksum_start_idx
    binary_str.size - (checksum_bitsize + StoryKey::FOOTER_BITSIZE)
  end

  def footer
    binary_str.last(StoryKey::FOOTER_BITSIZE)
  end

  def checksum_bitsize
    (StoryKey::BITS_PER_ENTRY * 2) - (tail_bitsize + StoryKey::FOOTER_BITSIZE)
  end

  def computed_checksum
    Digest::SHA256.hexdigest(bin_str)
                  .hex
                  .to_s(2)
                  .first(checksum_bitsize)
  end

  def decimals
    @decimals ||= tokens.map { |token| token_to_decimal(token) }
  end

  def token_to_decimal(token)
    lex.entries.each do |part, entries|
      next unless (idx = entries.index { |w| w.token == token })
      lex.entries[part] =
        if idx.zero?
          entries[1..]
        else
          entries[..(idx - 1)] + entries[(idx + 1)..]
        end
      return idx
    end
  end

  def words
    @words ||=
      story.split(/\s+/)
           .grep_v(/\A\d+\.\Z/)
           .map { |w| w.downcase.gsub(/[^a-z\d\-]/, '') }
           .reject { |w| w.blank? || w.in?(prepositions) }
  end

  def prepositions
    StoryKey::PREPOSITIONS + lex.prepositions
  end

  def tokens
    @tokens ||= [].tap do |tokens|
      idx = 0
      while idx < story_words.size
        token, idx = token_from_words(story_words, idx)
        tokens << token
      end
    end
  end

  def token_from_words(story_words, idx) # rubocop:disable Metrics/MethodLength
    word = story_words[idx]
    combined = StoryKey::Tokenizer.call("#{word} #{story_words[idx + 1]}")
    single = StoryKey::Tokenizer.call(word)
    token =
      if combined.in?(valid_tokens)
        idx += 1
        combined
      elsif single.in?(valid_tokens)
        single
      else
        raise StoryKey::InvalidWord, "Invalid word detected: '#{word}'"
      end

    [token, idx + 1]
  end

  def valid_tokens
    @valid_tokens ||= lex.entries.values.flatten.map(&:token)
  end

  def story_words
    @story_words ||= words[1..]
  end

  def version_word
    @version_word ||= words[0]
  end

  def lex
    @lex ||= StoryKey::Lexicon.new
  end
end
