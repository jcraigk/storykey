# frozen_string_literal: true

RSpec.describe Peartree::Lexicon do
  subject(:lex) { described_class.new }

  let(:regex) do
    /
      \A
      [a-zA-Z]
      [a-zA-Z0-9\-.]{1,15}
      (\s[a-zA-Z][a-zA-Z0-9\-]{1,15})?
      (\s\[[a-z]+\])?
      \Z
    /x
  end
  let(:linking_words) { %w[at for from in into of on out to up with] }
  let(:uniq_global_words) { global_words.map(&:downcase).uniq.sort }
  let(:global_words) { lex.words.values.flatten.map(&:text) }
  let(:min_pad_words) do
    ((MAX_INPUT_SIZE / BITS_PER_WORD.to_f) / GRAMMAR.first[1].count).ceil
  end
  let(:malformed_words) { global_words.grep_v(regex) }

  it 'matches expected sha' do
    expect(lex.sha).to eq(Peartree::LEXICON_SHA)
  end

  it 'returns expected word counts' do # rubocop:disable RSpec/ExampleLength
    total_count = 0
    LEXICONS.each do |part|
      count = (2**BITS_PER_WORD) + (min_pad_words * GRAMMAR.first[1].count { |p| p == part })
      total_count += count

      # num = lex.words[part].size
      # percent = (num / count.to_f) * 100
      # puts ">>>>>> #{part} count: #{num} of #{count} (#{percent.floor}%)"

      # Does not skip any contiguous decimals
      (0..(count - 1)).each do |decimal|
        expect(lex.words[part][decimal]).to be_a(Peartree::Lexicon::Word)
      end
    end

    expect(uniq_global_words.size).to eq(total_count)
  end

  it 'returns words of expected length and content' do
    expect(malformed_words).to be_empty
  end

  it 'returns unique words sorted by length and value' do
    LEXICONS.each do |part|
      words = lex.words[part]
      sorted_uniq = words.uniq.sort_by { |w| [w.text.size, w.text] }
      expect(sorted_uniq).to eq(words)
    end
  end

  it 'returns expected linking words' do
    expect(lex.linking_words).to eq(linking_words)
  end

  xit 'returns expected base words' do
  end

  xit 'returns lexicons that have unique 4-letter truncations' do
    lex.lexicons.each do |_, words|
      truncs = words.map { |w| w[0..3] }
      expect(truncs.uniq).to eq(truncs)
    end
  end

  xit 'produdes words of expected syllabic content' do
  end

  # Verify with external dictionary
  xit 'produces real English words' do
  end

  # Adjective "twisted" vs verb "twisting"
  # TODO: Is it bad or good to share bases?
  xit 'avoids the same base across lexicons' do
  end
end
