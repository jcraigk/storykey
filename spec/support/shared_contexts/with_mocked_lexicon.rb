# frozen_string_literal: true
RSpec.shared_context 'with mocked lexicon' do
  let(:min_pad_words) do
    ((StoryKey::MAX_BITSIZE / StoryKey::BITS_PER_ENTRY.to_f) / StoryKey::GRAMMAR.keys.max).ceil
  end
  let(:multiword_freq) { 15 }
  let(:preposition_freq) { 20 }
  let(:entries) do
    StoryKey::GRAMMAR.values.flatten.uniq.index_with do |part_of_speech|
      count =
        (2**StoryKey::BITS_PER_ENTRY) +
        (
          min_pad_words *
          StoryKey::GRAMMAR[StoryKey::GRAMMAR.keys.max].count { |p| p == part_of_speech }
        )
      (0..(count - 1)).map do |num|
        text = "#{part_of_speech}-#{num}"
        text = "pre-#{num} #{text}" if (num % multiword_freq).zero?
        text = "#{text} [with]" if part_of_speech == :verb && (num % preposition_freq).zero?
        StoryKey::Entry.new \
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
    allow(mock_lex).to receive(:entries).and_return(entries)
    allow(mock_lex).to receive(:prepositions).and_return(prepositions)
  end
end
