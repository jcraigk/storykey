# frozen_string_literal: true
class Peartree::Lexicon
  extend ::ActiveSupport::Concern

  def keywords
    @keywords ||= {}.tap do |hash|
      lexicons.each do |part_of_speech, words|
        words.each_with_index do |humanized, decimal|
          # TODO: use only first 4-5 chars later
          abbrev = humanized.split.first.downcase
          hash[abbrev] = Keyword.new(humanized:, part_of_speech:, decimal:)
        end

        # TODO: Fill out the real lexicon
        total = (2**BITS_PER_WORD) + NUM_PAD_WORDS
        num_real_words = words.size
        (num_real_words..(total - 1)).each do |decimal|
          suffix = (decimal / num_real_words.to_f).floor
          base_decimal = decimal - (num_real_words * suffix)
          base_word =
            hash.find do |_, v|
              v[:part_of_speech] == part_of_speech &&
                v[:decimal] == base_decimal
            end[1][:humanized]
          humanized = "#{base_word}#{suffix + 1}"
          abbrev = "#{base_word.split.first.downcase}#{suffix + 1}"
          hash[abbrev] = Keyword.new(humanized:, part_of_speech:, decimal:)
        end

        # binding.pry
      end
    end
  end

  # Any word after the first is a linking word,
  # included for aesthetics/grammar only
  def linking_words
    @linking_words ||= keywords.filter_map do |_, attrs|
      attrs[:humanized].split[1..]
    end.flatten.sort.uniq.grep_v(/\d/) # TODO
  end

  def all_humanized
    @all_humanized ||= lexicons.values.flatten.sort
  end

  def lexicons
    @lexicons ||= LEXICONS.index_with do |part_of_speech|
      read_txtfiles(part_of_speech)
    end
  end

  def sha
    Digest::SHA256.hexdigest(keywords.to_s).first(7)
  end

  private

  def read_txtfiles(part_of_speech)
    txtfiles(part_of_speech).map do |file|
      File.readlines(file)
          .map(&:strip)
          .reject do |line|
            line.start_with?('#') || line.blank?
          end
    end.flatten.sort
  end

  def txtfiles(part_of_speech)
    Dir.glob("lexicons/#{part_of_speech}s/*.txt")
  end

  Keyword = Struct.new \
    :humanized, :part_of_speech, :decimal, keyword_init: true
end
