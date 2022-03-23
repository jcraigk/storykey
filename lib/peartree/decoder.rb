# frozen_string_literal: true
class Peartree::Decoder < Peartree::Base
  param :str
  option :format, optional: true

  def call
    @str = str.strip
    @format ||= :hex

    validate_version!
    validate_words!
    validate_checksum!

    decoded_str
  end

  private

  def validate_version!
    return if version_word.casecmp(Peartree::VERSION_SLUG).zero?
    raise Peartree::InvalidVersion, version_error_msg
  end

  def validate_words!
    return unless decimals.include?(nil)
    raise Peartree::InvalidWord, 'Invalid word detected'
  end

  def version_error_msg
    <<~TEXT
      Missing or invalid version slug! Given '#{version_word.titleize}' but expected '#{Peartree::VERSION_SLUG}'.
    TEXT
  end

  def decoded_str
    Peartree::Coercer.call(binary_str, :bin, format)
  end

  def bin_str
    @bin_str ||=
      decimals.map do |dec|
        dec.to_s(2).rjust(BITS_PER_WORD, '0')
      end.join
  end

  def binary_str
    @binary_str ||= bin_str[0..(checksum_start_idx - 1)]
  end

  def validate_checksum!
    return if computed_checksum == embedded_checksum
    raise Peartree::InvalidChecksum, 'Checksum mismatch!'
  end

  def embedded_checksum
    bin_str[checksum_start_idx..-(FOOTER_BITSIZE + 1)]
  end

  def checksum_start_idx
    bin_str.size - (checksum_bitsize + FOOTER_BITSIZE)
  end

  def tail_bitsize
    Peartree::Coercer.call(footer, :bin, :dec).to_i
  end

  def footer
    bin_str.last(FOOTER_BITSIZE)
  end

  def checksum_bitsize
    (BITS_PER_WORD * 2) - (tail_bitsize + FOOTER_BITSIZE)
  end

  def computed_checksum
    Digest::SHA256.hexdigest(binary_str)
                  .hex
                  .to_s(2)
                  .first(checksum_bitsize)
  end

  def decimals
    return @decimals if @decimals

    @decimals = []
    idx = 0
    while idx < tokens.size
      token = tokens[idx]
      # Try two words first
      two_tokens = Peartree::Tokenizer.call("#{token}#{tokens[idx + 1]}")
      decimal = token_to_decimal(two_tokens)
      if decimal
        idx += 1
      else
        decimal = token_to_decimal(token)
      end
      idx += 1
      @decimals << decimal
    end

    @decimals
  end

  def token_to_decimal(token)
    lex.words.each do |part, words|
      idx = words.index { |w| w.token == token }
      next unless idx

      # Shift words to prevent repeats
      (idx..(lex.words[part].size - 2)).each do |x|
        lex.words[part][x] = lex.words[part][x + 1]
      end
      lex.words[part].pop

      return idx
    end

    nil
  end

  def words
    @words ||=
      str.split(/\s+/)
         .grep_v(/\A\d+\.\Z/)
         .map { |w| w.downcase.gsub(/[^a-z\d]/, '') }
         .reject { |w| w.blank? || w.in?(linking_words) }
  end

  def linking_words
    LINKING_WORDS + lex.linking_words
  end

  def tokens
    @tokens ||= story_words.map do |word|
      Peartree::Tokenizer.call(word)
    end
  end

  def story_words
    @story_words ||= words[1..]
  end

  def version_word
    @version_word ||= words[0]
  end

  def lex
    @lex ||= Peartree::Lexicon.new
  end
end
