# frozen_string_literal: true

RSpec.shared_context 'with mocked lexicon' do
  let(:booleans) { [true, false] }
  let(:min_pad_words) do
    ((MAX_INPUT_SIZE / BITS_PER_WORD.to_f) / GRAMMAR.first[1].count).ceil
  end
  let(:lexicons) do
    h = {}
    ('a'..'zzz').each_with_index { |w, i| h[i + 1] = w }
    LEXICONS.index_with do |part_of_speech|
      count =
        (2**BITS_PER_WORD) +
        (
          min_pad_words *
          GRAMMAR.first[1].count { |p| p == part_of_speech }
        )
      (0..(count - 1)).map do |num|
        Peartree::Lexicon::Word.new \
          "#{part_of_speech}-#{num}", (num % 1).zero?
      end
    end
  end
  let(:dictionary) do
    h = {}
    LEXICONS.each do |part_of_speech|
      lexicons[part_of_speech].each_with_index do |word, decimal|
        text = word.text
        countable = word.countable
        abbrev = text[0..(ABBREV_SIZE - 1)]
        h[abbrev] = Peartree::Lexicon::Keyword.new \
          text:,
          countable:,
          part_of_speech:,
          decimal:
      end
    end
    h
  end
  let(:mock_lex) { instance_spy(Peartree::Lexicon) }
  let(:linking_words) { %w[at on for] }

  before do
    allow(Peartree::Lexicon).to receive(:new).and_return(mock_lex)
    allow(mock_lex).to receive(:lexicons).and_return(lexicons)
    allow(mock_lex).to receive(:linking_words).and_return(linking_words)
    allow(mock_lex).to receive(:dictionary).and_return(dictionary)
  end
end
