# frozen_string_literal: true
class StoryKey::Decoder < StoryKey::Base
  option :story
  option :format, optional: true

  def call
    @story = story.strip
    @format ||= :base58

    # puts_debug

    validate_version!
    validate_checksum!

    decoded_str
  end

  private

  def decoded_str
    StoryKey::Coercer.call(str: bin_str, input: :bin, output: format)
  end

  def binary_str
    @binary_str ||=
      decimals.map do |dec|
        dec.to_s(2).rjust(BITS_PER_WORD, '0')
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
      input: :bin,
      output: :dec
    ).to_i
  end

  def embedded_checksum
    binary_str[checksum_start_idx..-(FOOTER_BITSIZE + 1)]
  end

  def checksum_start_idx
    binary_str.size - (checksum_bitsize + FOOTER_BITSIZE)
  end

  def footer
    binary_str.last(FOOTER_BITSIZE)
  end

  def checksum_bitsize
    (BITS_PER_WORD * 2) - (tail_bitsize + FOOTER_BITSIZE)
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
    lex.words.each do |part, words|
      next unless (idx = words.index { |w| w.token == token })
      lex.words[part] = words[..(idx - 1)] + words[(idx + 1)..]
      return idx
    end
  end

  def words
    @words ||=
      story.split(/\s+/)
           .grep_v(/\A\d+\.\Z/)
           .map { |w| w.downcase.gsub(/[^a-z\d]/, '') }
           .reject { |w| w.blank? || w.in?(prepositions) }
  end

  def prepositions
    PREPOSITIONS + lex.prepositions
  end

  def tokens
    @tokens ||= [].tap do |tokens|
      idx = 0
      while idx < story_words.size
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
        idx += 1
        tokens << token
      end
    end
  end

  def valid_tokens
    @valid_tokens ||= lex.words.values.flatten.map(&:token)
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

  def puts_debug
    puts "====DECODER===="
    puts "bin: #{bin_str}"
    puts "tokens: #{tokens}"
    puts "decimals: #{decimals}"
    puts "checksum: #{computed_checksum}"
    puts "embedded_checksum: #{embedded_checksum}"
    puts "checksum_bitsize: #{checksum_bitsize}"
    puts "tail_bitsize: #{tail_bitsize}"
  end
end
