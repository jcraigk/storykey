# frozen_string_literal: true
class Mnemonica::Decoder
  extend Dry::Initializer
  extend ::ActiveSupport::Concern

  param :str
  option :format

  def call
    @format ||= :hex

    validate_version!
    validate_time!
    validate_lexicon!
    validate_checksum!

    decoded_str
  end

  private

  def validate_time!
    return if last_segment_size <= BITS_PER_WORD
    raise Mnemonica::InvalidTime, 'Invalid time specified'
  end

  def validate_version!
    return if version_word.casecmp(Mnemonica::VERSION_SLUG).zero?
    raise Mnemonica::InvalidVersion, version_error_msg
  end

  def validate_lexicon!
    return unless decimals.include?(nil)
    raise Mnemonica::InvalidWord, 'Invalid word detected'
  end

  def version_error_msg
    <<~TEXT
      Missing or invalid version slug! Given '#{version_word.titleize}' but expected '#{Mnemonica::VERSION_SLUG}'.
    TEXT
  end

  def decoded_str
    case format.to_sym
    when :bin then binary_str
    when :dec then binary_str.to_i(2).to_s(10)
    when :hex then binary_str.to_i(2).to_s(16)
    else raise Mnemonica::InvalidFormat, 'Invalid format specified'
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
    raise Mnemonica::InvalidChecksum, 'Checksum incorrect - invalid phrase!'
  end

  def calculated_checksum
    Digest::SHA256.hexdigest(binary_str).hex.to_s(2).first(BITS_PER_WORD)
  end

  def decimals
    return @decimals if @decimals
    idx = -1
    @decimals = phrase_words.map do |word|
      idx += 1
      idx = idx % LEXICONS.size
      lexicon_words[LEXICONS[idx]].find_index(word)
    end
  end

  def words
    @words ||=
      str.split(/\s+/)
         .map(&:downcase)
         .reject do |word|
           word.match?(/\A\d+\.\Z/) ||
             word.in?(CONNECTING_WORDS)
         end
  end

  def phrase_words
    @phrase_words ||= words[2..]
  end

  def version_word
    @version_word ||= words.first
  end

  def last_segment_size
    @last_segment_size ||= words.second.gsub(/[^\d]/, '').to_i
  end

  def lexicon_words
    @lexicon_words ||= Mnemonica::Lexicon.call
  end
end
