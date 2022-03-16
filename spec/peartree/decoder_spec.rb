# frozen_string_literal: true

RSpec.describe Peartree::Decoder do
  subject(:call) { described_class.new(input, format:).call }

  let(:format) { nil }

  include_context 'with mocked lexicon'

  shared_examples 'success' do
    it 'returns expected output' do
      expect(call).to eq(output)
    end
  end

  describe 'invalid input' do
    context 'with missing or invalid version lead' do
      let(:input) do
        <<~TEXT.strip
          six adjectiveago noundcs verbmd an adjectivesd noundd,
          five adjectivealm nounmds verbaji an adjectivevm nounqo,
        TEXT
      end

      it 'raises an exception' do
        expect { call }.to raise_error(Peartree::InvalidVersion)
      end
    end

    context 'with invalid time' do
      let(:input) do
        <<~TEXT.strip
          In Miami at 12pm I saw an adjectiveago noundc verbme a nounhp
        TEXT
      end

      it 'raises an exception' do
        expect { call }.to raise_error(Peartree::InvalidTime)
      end
    end

    context 'with invalid word(s)' do
      let(:input) do
        <<~TEXT.strip
          In Miami at 1pm I saw a badword noundc verbme a nounhp
        TEXT
      end

      it 'raises an exception' do
        expect { call }.to raise_error(Peartree::InvalidWord)
      end
    end

    context 'with invalid checksum' do
      let(:input) do
        <<~TEXT.strip
          In Miami at 6pm I saw
          six adjectiveago noundcs verbmd an adjectivesd noundd,
          five adjectivealm nounmds verbaji an adjectivevm nounqo,
          four adjectiveol nounaags verbadb an adjectiveaew nounqq,
          three adjectiveale nounacjs verbagz an adjectiverf nounth,
          two adjectivekn nounhws verbhu an adjectivest nounry,
          and an adjectivewi nounbg
        TEXT
      end

      it 'raises an exception' do
        expect { call }.to raise_error(Peartree::InvalidChecksum)
      end
    end
  end

  context 'with valid input' do
    let(:input) do
      <<~TEXT.strip
        In Miami at 6pm I saw
        six adjectiveago noundcs verbmd an adjectivesd noundd,
        five adjectivealm nounmds verbaji an adjectivevm nounqo,
        four adjectiveol nounaags verbadb an adjectiveaew nounqq,
        three adjectiveale nounacjs verbagz an adjectiverf nounth,
        two adjectivekn nounhws verbhu an adjectivest nounry,
        and an adjectivewi nounbh
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

    # TODO: decide if means 256-bit-like (14 bits of checksum) OR
    # evenly-split-on-words-like (10 bits)
    # Always have at least 10 bits of checksum?
    xcontext 'when no time given' do
      let(:input) { super().gsub('at 6pm ', '') }
      let(:output) do
        <<~TEXT.strip
          asdf
        TEXT
      end
      let(:format) { :hex }

      include_examples 'success'
    end
  end
end
