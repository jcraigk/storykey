# frozen_string_literal: true
class Peartree::Lexicon
  extend ::ActiveSupport::Concern

  def lexicon
    @lexicon ||= {}.tap do |hash|
      humanized.each do |part_of_speech, words|
        words.each_with_index do |humanized, decimal|
          abbrev = humanized.downcase[0..(ABBREV_SIZE - 1)]
          hash[abbrev] = Keyword.new \
            humanized:, part_of_speech:, decimal:
        end
      end
    end
  end

  # Any word after the first is a linking word,
  # included for aesthetics/grammar
  def linking_words
    @linking_words ||= lexicon.filter_map do |_, attrs|
      attrs.humanized.split[1..]
    end.flatten.sort.uniq
  end

  def all_humanized
    @all_humanized ||= humanized.values.flatten.sort
  end

  def humanized
    @humanized ||= LEXICONS.index_with do |part_of_speech|
      read_txtfiles(part_of_speech)
    end
  end

  def sha
    Digest::SHA256.hexdigest(lexicon.to_s).first(7)
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
