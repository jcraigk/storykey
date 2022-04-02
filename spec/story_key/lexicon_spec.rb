# frozen_string_literal: true
RSpec.describe StoryKey::Lexicon do
  subject(:lex) { described_class.new }

  let(:regex) do
    /
      \A
      [a-zA-Z]
      [a-zA-Z0-9\-.]{1,15}
      (\s[a-zA-Z][a-zA-Z0-9\-]{1,15})?
      (\s\[[a-z]{1,5}\])?
      \Z
    /x
  end
  let(:prepositions) { %w[at for from in into of off on out over to up with] }
  let(:all_tokens) { all_entries.map(&:token).sort }
  let(:all_entries) { lex.entries.values.flatten }
  let(:min_pad_words) do
    ((MAX_KEY_SIZE / BITS_PER_WORD.to_f) / GRAMMAR.keys.max).ceil
  end
  let(:malformed_entries) { all_entries.map(&:raw).grep_v(regex) }
  let(:parts_of_speech) { GRAMMAR.values.flatten.uniq }

  it 'matches expected sha' do
    expect(lex.sha).to eq(StoryKey::LEXICON_SHA)
  end

  it 'returns expected entry counts' do # rubocop:disable RSpec/ExampleLength
    total_count = 0
    parts_of_speech.each do |part|
      count = (2**BITS_PER_WORD) + (min_pad_words * GRAMMAR.first[1].count { |p| p == part })
      total_count += count

      num = lex.entries[part].size
      percent = (num / count.to_f) * 100
      puts ">>>>>> #{part} count: #{num} of #{count} (#{percent.floor}%)"

      # Does not skip any contiguous decimals
      (0..(count - 1)).each do |decimal|
        expect(lex.entries[part][decimal]).to be_a(StoryKey::Lexicon::Entry)
      end
    end
    expect(all_tokens.size).to eq(total_count)
  end

  it 'returns a unique set of tokens' do
    # all_tokens.select { |e| all_tokens.count(e) > 1 }
    expect(all_tokens.uniq).to eq(all_tokens)
  end

  it 'returns entries of expected length and content' do
    expect(malformed_entries).to be_empty
  end

  it 'returns unique entries sorted by token' do
    parts_of_speech.each do |part|
      entries = lex.entries[part]
      expect(entries.uniq.sort_by(&:token)).to eq(entries)
    end
  end

  it 'returns expected prepositions' do
    expect(lex.prepositions).to eq(prepositions)
  end
end
