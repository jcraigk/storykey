# frozen_string_literal: true

RSpec.describe Mnemonica::Decoder do
  subject(:call) { described_class.new(input, format:).call }

  let(:format) { nil }
  let(:lexicon) do
    LEXICONS.index_with do |lex|
      (0..1_024).to_a.map { |num| "#{lex}#{num}" }
    end
  end

  before do
    allow(Mnemonica::Lexicon).to receive(:call).and_return(lexicon)
  end

  shared_examples 'success' do
    it 'returns expected output' do
      expect(call).to eq(output)
    end
  end

  describe 'invalid input' do
    context 'with missing or invalid version lead' do
      let(:input) do
        <<~TEXT.strip
          1. An adjective873 noun107 verb342 and verb498
          2. An adjective108 noun1001 verb342 and verb945
        TEXT
      end

      it 'raises an exception' do
        expect { call }.to raise_error(Mnemonica::InvalidVersion)
      end
    end

    context 'with missing or invalid time' do
      let(:input) do
        <<~TEXT.strip
          In Miami at 12pm I saw an adjective873 noun107 verb342 and verb498
        TEXT
      end

      it 'raises an exception' do
        expect { call }.to raise_error(Mnemonica::InvalidTime)
      end
    end

    context 'with invalid word(s)' do
      let(:input) do
        <<~TEXT.strip
          In Miami at 1pm I saw a badword noun107 verb342 and verb498
        TEXT
      end

      it 'raises an exception' do
        expect { call }.to raise_error(Mnemonica::InvalidWord)
      end
    end
  end

  context 'with valid input' do
    let(:input) do
      <<~TEXT.strip
        In Miami at 6pm I saw
        1. An adjective873 noun107 verb342 and verb498
        2. An adjective108 noun1001 verb342 and verb945
        3. An adjective585 noun457 verb402 and verb709
        4. An adjective782 noun829 verb459 and verb993
        5. An adjective764 noun884 verb474 and verb528
        6. An adjective300 noun231 verb229 and verb514
        7. An adjective493 noun37
      TEXT
    end

    context 'when format is hex' do
      let(:output) do
        <<~TEXT.strip
          da46b559f21b3e955bb1925c964ac5c3b3d72fe1bf37476a104b0e7396027b65
        TEXT
      end
      let(:format) { :hex }

      include_examples 'success'
    end

    context 'when format is dec' do
      let(:output) do
        <<~TEXT.strip
          98729131926707364344155946614204368554393612909660450514900410658357640330085
        TEXT
      end
      let(:format) { :dec }

      include_examples 'success'
    end

    context 'when format is bin' do
      let(:output) do
        <<~TEXT.strip
          1101101001000110101101010101100111110010000110110011111010010101010110111011000110010010010111001001011001001010110001011100001110110011110101110010111111100001101111110011011101000111011010100001000001001011000011100111001110010110000000100111101101100101
        TEXT
      end
      let(:format) { :bin }

      include_examples 'success'
    end
  end
end
