# frozen_string_literal: true
class Peartree::Decoder < Peartree::Base
  param :str
  option :format, optional: true

  def call
    @str = str.strip
    @format ||= :hex

    validate_version!
    validate_time!
    validate_words!
    validate_checksum!

    decoded_str
  end

  private

  def validate_time!
    return if tail_bitsize <= BITS_PER_WORD
    raise Peartree::InvalidTime, 'Invalid time specified'
  end

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
        num_bits = idx + 1 == decimals.size ? tail_bitsize : BITS_PER_WORD
        dec.to_s(2).rjust(num_bits, '0')
      end.join
  end

  def binary_str
    @binary_str ||= bin_str[0..-(BITS_PER_WORD + 1)]
  end

  def validate_checksum!
    return if checksum == (bits = bin_str.last(BITS_PER_WORD))
    raise Peartree::InvalidChecksum, "Checksum '#{checksum}' mismatch with '#{bits}'!"
  end

  def checksum
    Digest::SHA256.hexdigest(binary_str)
                  .hex
                  .to_s(2)
                  .first(BITS_PER_WORD)
  end

  def decimals
    @decimals ||= abbrevs.map { |abbrev| lex.lexicon[abbrev]&.decimal }
  end

  def words
    @words ||=
      str.split(/\s+/)
         .map(&:downcase)
         .map { |word| word.tr(',', '') }
         .map(&:singularize)
         .reject { |word| word.in?(LINKING_WORDS + lex.linking_words) }
  end

  def abbrevs
    @abbrevs ||= phrase.map { |w| w[0..(ABBREV_SIZE - 1)] }
  end

  def phrase
    @phrase ||= words[(time_given? ? 2 : 1)..]
  end

  def version_word
    @version_word ||= words[0]
  end

  # A "time" can be provided in poem header
  # to indicate number of bits encoded in final word.
  # "9pm" indicates 9 bits
  # If no time specified, default to BITS_PER_WORD
  def tail_bitsize
    @tail_bitsize ||= time_given? ? bitsize_from_time : default_bitsize
  end

  def default_bitsize
    DEFAULT_INPUT_SIZE % BITS_PER_WORD
  end

  def bitsize_from_time
    words[1].gsub(/[^\d]/, '').to_i
  end

  def time_given?
    @time_given ||= words[1].match?(/\A\d{1,2}(?:pm|Pm|pM|PM)/)
  end

  def lex
    @lex ||= Peartree::Lexicon.new
  end
end
