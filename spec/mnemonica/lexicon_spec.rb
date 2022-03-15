# frozen_string_literal: true

RSpec.describe Mnemonica::Lexicon do
  subject(:result) { described_class.call }

  let(:sha) { Digest::SHA256.hexdigest(result.flatten.join) }
  let(:count) { (2**BITS_PER_WORD) + NUM_PAD_WORDS }
  let(:all_words) do
    LEXICONS.inject([]) { |words, lexicon| words + result[lexicon] }
  end
  let(:regex) { /\A[A-Za-z0-9]{3,15}\Z/ } # TODO: remove digits

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

  it 'returns unique global downcased lexicon' do
    all_words.select { |e| all_words.count(e) > 1 }
    expect(all_words.map(&:downcase).uniq.size).to eq(all_words.size)
  end

  it 'returns verbs all ending with `ing`' do
    expect(result[:verb].grep_v(/\ing\d?\Z/)).to be_empty # TODO: remove digit
  end

  xit 'returns lexicons that have unique 3-letter truncations' do
    LEXICONS.each do |lexicon|
      truncations = result[lexicon].map { |word| word[0..2] }
      expect(truncations.uniq).to eq(truncations)
    end
  end

  it 'returns words of expected length and content' do
    expect(all_words.grep_v(regex)).to be_empty
  end

  it 'produces expected global sha' do
    expect(sha).to eq(Mnemonica::LEXICON_SHA)
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
