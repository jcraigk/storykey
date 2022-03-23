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
    @decimals ||= base_words.map { |w| base_word_to_dec(w) }
  end

  def base_word_to_dec(base_word)
    lex.base_words.each do |part_of_speech, base_words|
      idx = base_words.index(base_word)
      next unless idx

      # Shift words to prevent repeats
      (idx..(base_words.size - 2)).each do |x|
        base_words[x] = base_words[x + 1]
      end
      lex.base_words[part_of_speech] = base_words[0..-2]

      return idx
    end

    nil
  end

  def words
    @words ||=
      str.split(/\s+/)
         .grep_v(/\A\d+\.\Z/)
         .map { |w| w.downcase.gsub(/[^a-z\-\d]/, '') }
         .reject { |w| w.blank? || w.in?(linking_words) }
  end

  def linking_words
    LINKING_WORDS + lex.linking_words
  end

  def base_words
    @base_words ||= story_words.map { |w| w[0..(ABBREV_SIZE - 1)] }
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
