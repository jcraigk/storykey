# frozen_string_literal: true

RSpec.shared_context 'with mocked lexicon' do
  let(:booleans) { [true, false] }
  let(:min_pad_words) do
    ((MAX_INPUT_SIZE / BITS_PER_WORD.to_f) / GRAMMAR.first[1].count).ceil
  end
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
          if part_of_speech == :noun
            if (num % 1).zero?
              base
            else
              "pre-#{num} #{base}"
            end
          elsif part_of_speech == :verb && (num % 20).zero?
            "#{base} [with]"
          end
        Peartree::Lexicon::Word.new \
          text, (num % 1).zero?
      end
    end
  end
  let(:base_words) do
    words.transform_values do |ary|
      ary.map do |word|
        Peartree::Tokenizer.call(word.text)
      end
    end
  end
  let(:mock_lex) { instance_spy(Peartree::Lexicon) }
  let(:linking_words) { %w[at on for] }

  before do
    allow(Peartree::Lexicon).to receive(:new).and_return(mock_lex)
    allow(mock_lex).to receive(:words).and_return(words)
    allow(mock_lex).to receive(:linking_words).and_return(linking_words)
    allow(mock_lex).to receive(:base_words).and_return(base_words)
  end
end
