# frozen_string_literal: true

RSpec.describe Peartree::Lexicon do
  subject(:lex) { described_class.new }

  let(:count) { (2**BITS_PER_WORD) + NUM_PAD_WORDS }
  let(:regex) { /\A(?:[A-Za-z0-9]{3,15})\s?(?:[a-z0-9]{2,5})?\Z/ }
  let(:linking_words) { %w[at for from of on to up with] }

  it 'matches expected sha' do
    expect(lex.sha).to eq(Peartree::LEXICON_SHA)
  end

  it 'returns expected word count' do
    LEXICONS.each do |part_of_speech|
      num = lex.lexicons[part_of_speech].grep_v(/\d/).size
      percent = (num / count.to_f) * 100
      puts "Actual #{part_of_speech} count: #{num} (#{percent.floor}%)"
    end
    expect(lex.keywords.size).to eq(count * LEXICONS.size)
  end

  it 'does not skip any decimals' do
    LEXICONS.each do |part_of_speech|
      (0..(count - 1)).each do |decimal|
        keyword = lex.keywords.find do |_, v|
          v[:part_of_speech] == part_of_speech &&
            v[:decimal] == decimal
        end
        expect(keyword).not_to be_empty
      end
    end
  end

  it 'returns words of expected length and content' do
    expect(lex.all_humanized.grep_v(regex)).to be_empty
  end

  it 'returns unique global downcased lexicon' do
    # lex.all_humanized.select { |w| lex.all_humanized.count(w) > 1 }.map { |w| w.gsub(/\d/, '') }.uniq
    uniq = lex.all_humanized.map(&:downcase).uniq
    expect(uniq.size).to eq(lex.all_humanized.size)
  end

  it 'returns unique words for each part of speech' do
    LEXICONS.each do |part_of_speech|
      words = lex.lexicons[part_of_speech]
      # TODO: add sort later
      expect(words.uniq).to eq(words)
    end
  end

  it 'returns expected linking words' do
    expect(lex.linking_words).to eq(linking_words)
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
