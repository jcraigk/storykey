# frozen_string_literal: true

RSpec.describe Peartree::Lexicon do
  subject(:lex) { described_class.new }

  let(:regex) { /\A(?:[A-Za-z0-9]{3,15})\s?(?:[a-z0-9]{2,5})?\Z/ }
  let(:linking_words) { %w[at for from in into of on out to up with] }
  let(:uniq_text) { lex.lexicons.values.flatten.map(&:text).map(&:downcase).sort }
  let(:min_pad_words) do
    ((MAX_INPUT_SIZE / BITS_PER_WORD.to_f) / GRAMMAR.first[1].count).ceil
  end
  let(:malformed_words) do
    lex.dictionary.map { |_, v| v.text }.grep_v(regex)
  end

  it 'matches expected sha' do
    expect(lex.sha).to eq(Peartree::LEXICON_SHA)
  end

  it 'returns expected word counts' do
    total_count = 0
    LEXICONS.each do |part|
      num = lex.lexicons[part].map(&:text).size
      count = (2**BITS_PER_WORD) + (min_pad_words * GRAMMAR.first[1].count { |p| p == part })
      total_count += count

      percent = (num / count.to_f) * 100
      puts ">>>>>> #{part} count: #{num} of #{count} (#{percent.floor}%)"

      # Does not skip any decimals
      (0..(count - 1)).each do |decimal|
        keyword = lex.dictionary.find do |_, v|
          v.part_of_speech == part && v.decimal == decimal
        end
        expect(keyword).not_to be_empty
      end
    end

    expect(lex.dictionary.size).to eq(total_count)
    expect(uniq_text.size).to eq(total_count)
  end

  it 'returns words of expected length and content' do
    expect(malformed_words).to be_empty
  end

  it 'returns unique words for each part of speech' do
    LEXICONS.each do |part|
      words = lex.lexicons[part].map(&:text)
      # words.select { |e| words.count(e) > 1 }.uniq.sort
      expect(words.uniq.sort).to eq(words)
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
