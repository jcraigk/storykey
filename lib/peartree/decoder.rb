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
      decimals.each_with_index.map do |dec, idx|
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
    @decimals ||= abbrevs.map do |abbrev|
      lex.dictionary[abbrev].decimal
    end
  end

  def words
    @words ||=
      str.split(/\s+/)
         .map { |w| w.downcase.gsub(/[^a-z]/, '') }
         .reject { |w| w.blank? || w.in?(linking_words) }
  end

  def linking_words
    LINKING_WORDS + lex.linking_words
  end

  def word_of_type?(word, part_of_speech)
    lex.dictionary[abbrev(word)]&.part_of_speech == part_of_speech
  end

  def abbrevs
    @abbrevs ||= phrase_words.map { |w| abbrev(w) }
  end

  def abbrev(word)
    word[0..(ABBREV_SIZE - 1)]
  end

  def phrase_words
    @phrase_words ||= words[1..]
  end

  def version_word
    @version_word ||= words[0]
  end

  def lex
    @lex ||= Peartree::Lexicon.new
  end
end
