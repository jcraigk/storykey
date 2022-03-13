# frozen_string_literal: true
class Mnemonica::Encoder
  extend Dry::Initializer

  param :str
  option :format

  def call
    @str = str.strip
    @format ||= :hex
    validate_format!
    paragraph
  end

  private

  def paragraph
    "#{version_lead}\n#{enumerated_phrases.join("\n")}"
  end

  def version_lead
    "In #{Mnemonica::VERSION_SLUG} I saw"
  end

  def enumerated_phrases
    raw_phrases.each_with_index.map do |phrase, idx|
      "#{idx + 1}. #{phrase.with_indefinite_article.humanize}"
    end
  end

  def raw_phrases
    phrase = ''
    words.each_with_index.with_object([]) do |(word, idx), phrases|
      lex_idx = idx % LEXICONS.size
      phrase += 'and ' if lex_idx == LEXICONS.size - 1
      phrase += "#{word} "
      if (lex_idx == LEXICONS.size - 1) || (idx == words.size - 1)
        phrases << phrase.strip
        phrase = ''
      end
    end
  end

  def words
    idx = -1
    decimals.map do |dec|
      idx += 1
      idx = idx % LEXICONS.size
      lexicon_words[LEXICONS[idx]][dec]
    end
  end

  def lexicon_words
    @lexicon_words ||= Mnemonica::Lexicon.new.call
  end

  def decimals
    bin_segments.map { |b| bin_to_dec(b) }
  end

  def bin_to_dec(bin)
    bin.reverse.chars.map.with_index do |digit, index|
      digit.to_i * (2**index)
    end.sum
  end

  def bin_segments
    idx = 0
    parts = []
    while idx < bin_str.size
      parts << bin_str[idx..(idx + BITS_PER_WORD - 1)]
      idx += BITS_PER_WORD
    end
    parts
  end

  def validate_format!
    case format.to_sym
    when :bin then validate_bin!
    when :dec then validate_dec!
    when :hex then validate_hex!
    else raise_invalid_format("Invalid format given: #{format}")
    end
  end

  def validate_bin!
    return if str.match?(/\A[0-1]+\Z/)
    raise_invalid_format('Binary format specified but data contains invalid characters')
  end

  def validate_dec!
    return if str.match?(/\A[0-9]+\Z/)
    raise_invalid_format('Decimal format specified but data contains invalid characters')
  end

  def validate_hex!
    return if str.match?(/\A[0-9a-f]+\Z/)
    raise_invalid_format('Hexidecimal format specified but data contains invalid characters')
  end

  def bin_str
    @bin_str ||=
      case format&.to_sym
      when :bin then str
      when :dec then str.to_i.to_s(2)
      when :hex then str.hex.to_s(2)
      else raise_invalid_format('Invalid format specified, valid options are bin, dec, and hex')
      end
  end

  def raise_invalid_format(msg)
    raise Mnemonica::InvalidFormat, msg
  end
end
