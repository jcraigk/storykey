# frozen_string_literal: true

RSpec.shared_context 'with mocked lexicon' do
  let(:count) { (2**BITS_PER_WORD) + NUM_PAD_WORDS }
  let(:humanized) do
    h = {}
    ('a'..'zzz').each_with_index { |w, i| h[i + 1] = w }
    LEXICONS.index_with do |part_of_speech|
      (0..(count - 1)).map { |num| "#{part_of_speech}#{h[num]}" }
    end
  end
  let(:lexicon) do
    h = {}
    LEXICONS.each do |part_of_speech|
      humanized[part_of_speech].each_with_index do |word, decimal|
        abbrev = word[0..(ABBREV_SIZE - 1)]
        h[abbrev] = Peartree::Lexicon::Keyword.new(humanized: word, decimal:)
      end
    end
    h
  end
  let(:mock_lex) { instance_spy(Peartree::Lexicon) }
  let(:linking_words) { %w[at on for] }

  before do
    allow(Peartree::Lexicon).to receive(:new).and_return(mock_lex)
    allow(mock_lex).to receive(:humanized).and_return(humanized)
    allow(mock_lex).to receive(:linking_words).and_return(linking_words)
    allow(mock_lex).to receive(:lexicon).and_return(lexicon)
  end
end
