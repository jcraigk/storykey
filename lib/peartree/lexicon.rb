# frozen_string_literal: true
class Peartree::Lexicon
  extend ::ActiveSupport::Concern

  def self.call
    LEXICONS.index_with do |lexicon|
      words = []
      Dir.glob("lexicons/#{lexicon}s/*.txt") do |file|
        words += File.readlines(file).reject(&:blank?).map(&:strip)
      end

      # TODO: Fill out the real lexicon
      num_real_words = idx = words.size
      count = (2**BITS_PER_WORD) + NUM_PAD_WORDS
      while idx < count
        suffix = (idx / num_real_words.to_f).floor
        words[idx] = "#{words[idx - (num_real_words * suffix)]}#{suffix + 1}"
        idx += 1
      end

      words.sort
    end
  end
end
