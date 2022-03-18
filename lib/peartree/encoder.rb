# frozen_string_literal: true
class Peartree::Encoder < Peartree::Base
  param :str
  option :format, optional: true

  def call
    @str = str.strip
    @format ||= :hex

    validate_format!
    validate_length!

    Result.new(text, colorized)
  end

  private

  def text
    @text ||= colorized.no_color
  end

  def colorized
    @colorized ||= "#{version_str}#{newline}#{phrases.join(",\n")}"
  end

  def validate_length!
    return if bin_str.size <= MAX_INPUT_SIZE
    raise Peartree::InputTooLarge, "Max input size is #{MAX_INPUT_SIZE} bits"
  end

  def newline
    num_phrases == 1 ? ' ' : "\n"
  end

  def version_str
    "In #{Peartree::VERSION_SLUG.cyan} I saw"
  end

  def last_segment_size
    bin_segments.last.size
  end

  # Checksum uses any remaining bits in last segment
  # Plus 6 more bits in the last word
  # Before the final 4 tail bits
  def checksum_bitsize
    (BITS_PER_WORD * 2) - (tail_bitsize + FOOTER_BITSIZE)
  end

  def tail_bitsize
    (bin_str.size % BITS_PER_WORD)
  end

  def num_phrases
    raw_phrases.size
  end

  def phrases
    raw_phrases.each_with_index.map do |phrase, idx|
      parts = []
      if num_phrases > 1
        parts << "#{idx + 1}."
        parts << 'and' if idx == num_phrases - 1
      end
      parts << phrase.no_color.indefinite_article
      parts << phrase
      parts.join(' ')
    end
  end

  def highlight(word)
    abbrev = word[0..(ABBREV_SIZE - 1)]
    tail = word[(ABBREV_SIZE - 1)..]
    "#{abbrev.magenta}#{tail&.bold}"
  end

  def raw_phrases # rubocop:disable Metrics/MethodLength
    phrase = ''
    words.each_with_index.with_object([]) do |(word, idx), phrases|
      speech_idx = idx % num_grammar_parts
      highlighted_singular = highlight(word)
      phrase +=
        if speech_idx.in?([3, 5]) # Second adjective
          "#{word.indefinite_article} #{highlighted_singular}"
        else
          highlighted_singular
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
    Peartree::Coercer.call(bin, :bin, :dec).to_i
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
    return @binary_str if @binary_str
    @binary_str ||= bin_str + checksum + footer
  end

  def footer
    tail_bitsize.to_s(2).rjust(FOOTER_BITSIZE, '0')
  end

  def bin_str
    @bin_str ||= Peartree::Coercer.call(str, format, :bin)
  end

  def checksum
    Digest::SHA256.hexdigest(bin_str)
                  .hex
                  .to_s(2)
                  .first(checksum_bitsize)
  end

  def raise_invalid_format(msg)
    raise Peartree::InvalidFormat, msg
  end

  Result = Struct.new(:text, :colorized)
end
