# frozen_string_literal: true
class Peartree::Decoder
  extend Dry::Initializer
  extend ::ActiveSupport::Concern

  param :str
  option :format

  def call
    @format ||= :hex
    @linking_words = []

    validate_version!
    validate_time!
    validate_phrase!
    validate_checksum!

    decoded_str
  end

  private

  def validate_time!
    return if last_segment_size <= BITS_PER_WORD
    raise Peartree::InvalidTime, 'Invalid time specified'
  end

  def validate_version!
    return if version_word.casecmp(Peartree::VERSION_SLUG).zero?
    raise Peartree::InvalidVersion, version_error_msg
  end

  def validate_phrase!
    return unless decimals.include?(nil)
    raise Peartree::InvalidWord, 'Invalid word detected'
  end

  def version_error_msg
    <<~TEXT
      Missing or invalid version slug! Given '#{version_word.titleize}' but expected '#{Peartree::VERSION_SLUG}'.
    TEXT
  end

  def decoded_str
    case format.to_sym
    when :bin then binary_str
    when :dec then binary_str.to_i(2).to_s(10)
    when :hex then binary_str.to_i(2).to_s(16)
    else raise Peartree::InvalidFormat, 'Invalid format specified'
    end
  end

  def bin_str
    @bin_str ||=
      decimals.each_with_index.map do |dec, idx|
        num_bits = idx + 1 == decimals.size ? last_segment_size : BITS_PER_WORD
        dec.to_s(2).rjust(num_bits, '0')
      end.join
  end

  def binary_str
    @binary_str ||= bin_str[0..-(BITS_PER_WORD + 1)]
  end

  def validate_checksum!
    return if calculated_checksum == bin_str.last(BITS_PER_WORD)
    raise Peartree::InvalidChecksum, 'Checksum incorrect - invalid phrase!'
  end

  def calculated_checksum
    Digest::SHA256.hexdigest(binary_str).hex.to_s(2).first(BITS_PER_WORD)
  end

  def decimals
    @decimals ||= phrase_words.map { |word| lex.decimal_map[word] }
  end

  def words
    @words ||=
      str.split(/\s+/)
         .map(&:downcase)
         .map { |word| word.tr(',', '') }
         .map(&:singularize)
         .reject { |word| word.in?(LINKING_WORDS + lex.linking_words) }
  end

  def phrase_words
    @phrase_words ||= words[2..]
  end

  def version_word
    @version_word ||= words[0]
  end

  def last_segment_size
    @last_segment_size ||= words[1].gsub(/[^\d]/, '').to_i
  end

  def lex
    @lex ||= Peartree::Lexicon.call
  end

  def keywords
    @keywords ||= lex.keywords
  end
end
