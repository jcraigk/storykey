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
        In #{Peartree::VERSION_SLUG} at 2pm I saw
        six adjectiveago noundcs verbmd an adjectivesd noundd,
        five adjectivealm nounmds verbaji an adjectivevm nounqo,
        four adjectiveol nounaags verbadb an adjectiveaew nounqq,
        three adjectiveale nounacjs verbagz an adjectiverf nounth,
        two adjectivekn nounhws verbhu an adjectivest nounry,
        and an adjectiveaaq nounb
      TEXT
    end

    context 'when format is hex' do
      let(:output) do
        <<~TEXT.strip
          da46b559f21b3e955bb1925c964ac5c3b3d72fe1bf37476a104b0e7396027b6
        TEXT
      end
      let(:format) { :hex }

      include_examples 'success'
    end

    context 'when format is dec' do
      let(:output) do
        <<~TEXT.strip
          6170570745419210271509746663387773034649600806853778157181275666147352520630
        TEXT
      end
      let(:format) { :dec }

      include_examples 'success'
    end

    context 'when format is bin' do
      let(:output) do
        <<~TEXT.strip
          110110100100011010110101010110011111001000011011001111101001010101011011101100011001001001011100100101100100101011000101110000111011001111010111001011111110000110111111001101110100011101101010000100000100101100001110011100111001011000000010011110110110
        TEXT
      end
      let(:format) { :bin }

      include_examples 'success'
    end

    context 'when no time is given' do
      let(:input) do
        <<~TEXT.strip
          In #{Peartree::VERSION_SLUG} I saw
          six adjectiveago noundcs verbmd an adjectivesd noundd,
          five adjectivealm nounmds verbaji an adjectivevm nounqo,
          four adjectiveol nounaags verbadb an adjectiveaew nounqq,
          three adjectiveale nounacjs verbagz an adjectiverf nounth,
          two adjectivekn nounhws verbhu an adjectivest nounry,
          and an adjectivewi nounbh
        TEXT
      end
      let(:output) do
        <<~TEXT.strip
          da46b559f21b3e955bb1925c964ac5c3b3d72fe1bf37476a104b0e7396027b65
        TEXT
      end
      let(:format) { :hex }

      include_examples 'success'
    end
  end
end
