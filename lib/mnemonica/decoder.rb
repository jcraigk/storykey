# frozen_string_literal: true
class Mnemonica::Decoder
  extend Dry::Initializer
  extend ::ActiveSupport::Concern

  param :str
  option :format

  def call
    @format ||= :hex

    ensure_version!
    ensure_format!
    decoded
  end

  private

  def ensure_format!
    # @format ||= :hex
  end

  def ensure_version!
    return if version_word.casecmp(Mnemonica::VERSION_SLUG).zero?
    raise Mnemonica::InvalidVersion, version_error_msg
  end

  def version_error_msg
    <<~TEXT
      Missing or invalid version slug! (Given '#{version_word.titleize}' but this version of the software expects '#{Mnemonica::VERSION_SLUG}').
    TEXT
  end

  def decoded
    case format.to_sym
    when :bin then bin_str
    when :dec then bin_str.to_i(2).to_s(10)
    when :hex then bin_str.to_i(2).to_s(16)
    else raise Mnemonica::InvalidFormat, 'Invalid format specified, valid options are bin, dec, and hex' # TODO: DRY
    end
  end

  def bin_str
    decimals.map { |d| d.to_s(2).rjust(BITS_PER_WORD, '0') }.join
  end

  def decimals
    idx = -1
    phrase_words.map do |word|
      idx += 1
      idx = idx % LEXICONS.size
      lexicon_words[LEXICONS[idx]].find_index(word)
    end
  end

  def words
    @words ||=
      str.split(/\s+/)
         .map(&:downcase)
         .select do |word|
           word.match?(/\A[a-z]+\Z/) &&
             !word.in?(CONNECTING_WORDS)
         end
  end

  def phrase_words
    @phrase_words ||= words[1..]
  end

  def version_word
    words.first
  end

  def lexicon_words
    @lexicon_words ||= Mnemonica::Lexicon.new.call
  end
end
