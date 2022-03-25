# frozen_string_literal: true

RSpec.shared_context 'with mocked lexicon' do
  let(:min_pad_words) do
    ((MAX_INPUT_SIZE / BITS_PER_WORD.to_f) / GRAMMAR.first[1].count).ceil
  end
  let(:multinoun_frequency) { 7 }
  let(:preposition_frequency) { 20 }
  let(:words) do
    LEXICONS.index_with do |part_of_speech|
      count =
        (2**BITS_PER_WORD) +
        (
          min_pad_words *
          GRAMMAR.first[1].count { |p| p == part_of_speech }
        )
      (0..(count - 1)).map do |num|
        base = "#{part_of_speech}-#{num}"
        text =
          if part_of_speech == :noun && (num % multinoun_frequency).zero?
            "pre-#{num} #{base}"
          elsif part_of_speech == :verb && (num % preposition_frequency).zero?
            "#{base} [with]"
          else
            base
          end
        StoryKey::Lexicon::Word.new \
          token: StoryKey::Tokenizer.call(text),
          text: text.gsub(/\[|\]/, ''),
          countable: (num % 1).zero?,
          preposition: text.match(/\[(.+)\]/).to_a[1]
      end
    end
  end
  let(:mock_lex) { instance_spy(StoryKey::Lexicon) }
  let(:prepositions) { %w[at on for] }

  before do
    allow(StoryKey::Lexicon).to receive(:new).and_return(mock_lex)
    allow(mock_lex).to receive(:words).and_return(words)
    allow(mock_lex).to receive(:prepositions).and_return(prepositions)
  end
end
