# frozen_string_literal: true

RSpec.describe Mnemonica::Lexicon do
  subject(:result) { described_class.call }

  let(:sha) { Digest::SHA256.hexdigest(result.flatten.join) }
  let(:count) { 1_024 }
  let(:min_length) { 3 }
  let(:max_length) { 12 }
  let(:all_words) do
    LEXICONS.inject([]) { |words, lexicon| words + result[lexicon] }
  end
  let(:invalid_words) do
    all_words.select do |word|
      word.size < min_length || word.size > max_length
    end
  end

  it 'returns expected word counts' do
    LEXICONS.each do |lexicon|
      expect(result[lexicon].size).to eq(count)
    end
  end

  it 'returns unique sorted words within each lexicon' do
    LEXICONS.each do |lexicon|
      expect(result[lexicon].uniq.sort).to eq(result[lexicon])
    end
  end

  it 'returns unique global lexicon' do
    # all_words.detect { |e| all_words.count(e) > 1 }
    expect(all_words.uniq).to eq(all_words)
  end

  it 'returns lexicons that have unique 3-letter truncations' do
    LEXICONS.each do |lexicon|
      truncations = result[lexicon].map { |word| word[0..2] }
      expect(truncations.uniq).to eq(truncations)
    end
  end

  it 'returns words of expected length' do
    expect(invalid_words).to be_empty
  end

  it 'produces expected global sha' do
    expect(sha).to eq(Mnemonica::LEXICON_SHA)
  end

  xit 'produdes words of expected syllabic content' do
  end
end
