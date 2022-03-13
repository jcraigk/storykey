# frozen_string_literal: true
class Mnemonica::Lexicon
  extend ::ActiveSupport::Concern

  def call
    LEXICONS.index_with do |lexicon|
      File.readlines("lexicons/#{lexicon}s.txt").map(&:strip)
    end
  end
end
