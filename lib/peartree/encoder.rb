# frozen_string_literal: true
class Peartree::Encoder
  extend Dry::Initializer

  param :str
  option :format

  def call
    @str = str.strip
    @format ||= :hex

    validate_format!
    validate_length!

    paragraph
  end

  private

  def validate_length!
    return if bin_str.size <= MAX_INPUT_BITS
    raise Peartree::InputTooLarge, "Max input size is #{MAX_INPUT_BITS} bits"
  end

  def paragraph
    maybe_newline = num_phrases == 1 ? ' ' : "\n"
    "#{version_lead}#{maybe_newline}#{enumerated_phrases.join(",\n")}"
  end

  def version_lead
    "In #{Peartree::VERSION_SLUG} #{time}I saw"
  end

  def time
    return if last_segment_size == BITS_PER_WORD
    "at #{last_segment_size}pm "
  end

  def last_segment_size
    @last_segment_size ||= bin_segments.last.size
  end

  def num_phrases
    @num_phrases ||= raw_phrases.size
  end

  def enumerated_phrases
    raw_phrases.each_with_index.map do |phrase, idx|
      if idx == num_phrases - 1
        str = phrase.with_indefinite_article
        num_phrases == 1 ? str : "and #{str}"
      else
        "#{(raw_phrases.size - idx).humanize} #{phrase}"
      end
    end
  end

  def raw_phrases # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    phrase = ''
    words.each_with_index.with_object([]) do |(word, idx), phrases|
      speech_idx = idx % num_grammar_parts
      phrase +=
        case speech_idx
        when 1 # First noun
          # If last phrase, singularize
          if idx > words.size - num_grammar_parts
            word
          else
            word.pluralize
          end
        when 3 # Second adjective
          word.with_indefinite_article
        else
          word
        end
      phrase += ' '
      if phrase_done?(speech_idx, idx)
        phrases << phrase.strip
        phrase = ''
      end
    end
  end

  # The last phrase may be partial
  def phrase_done?(speech_idx, idx)
    (speech_idx == num_grammar_parts - 1) || (idx == words.size - 1)
  end

  def num_grammar_parts
    GRAMMAR.size
  end

  def words
    decimals.each_with_index.map do |decimal, idx|
      speech_idx = idx % num_grammar_parts
      part_of_speech = GRAMMAR[speech_idx]
      # Substitude a noun if last word is adjective
      part_of_speech = :noun if idx == decimals.size - 1 && part_of_speech == :adjective
      lex.humanized[part_of_speech][decimal]
    end
  end

  def lex
    @lex ||= Peartree::Lexicon.new
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
    while idx < binary_str.size
      parts << binary_str[idx..(idx + BITS_PER_WORD - 1)]
      idx += BITS_PER_WORD
    end
    parts
  end

  def validate_format!
    # binding.pry
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

  def binary_str
    @binary_str ||= bin_str + checksum
  end

  def bin_str
    @bin_str ||=
      case format&.to_sym
      when :bin then str
      when :dec then str.to_i.to_s(2)
      when :hex then str.hex.to_s(2)
      else raise_invalid_format('Invalid format specified')
      end
  end

  def checksum
    Digest::SHA256.hexdigest(bin_str).hex.to_s(2).first(BITS_PER_WORD)
  end

  def raise_invalid_format(msg)
    raise Peartree::InvalidFormat, msg
  end
end
