# frozen_string_literal: true
class Mnemonica::Lexicon
  extend ::ActiveSupport::Concern

  def self.call
    LEXICONS.uniq.index_with do |lexicon|
      words = []
      Dir.glob("lexicons/#{lexicon}s/*.txt") do |file|
        words += File.readlines(file).compact.map(&:strip)
      end
      words.sort
    end
  end
end
