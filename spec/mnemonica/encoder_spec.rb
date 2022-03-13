# frozen_string_literal: true

RSpec.describe Mnemonica::Encoder do
  subject(:call) { described_class.new(encodable, format:).call }

  let(:format) { nil }

  shared_examples 'success' do
    it 'returns expected output' do
      expect(call).to eq(output)
    end
  end

  shared_examples 'invalid format' do
    it 'raises an exception' do
      expect { call }.to raise_error(Mnemonica::InvalidFormat)
    end
  end

  context 'with invalid input' do
    context 'when invalid hex' do
      let(:encodable) { '23az939fs2' }

      include_examples 'invalid format'
    end

    context 'when invalid decimal' do
      let(:encodable) { '' }
      let(:dec) { '34234abc2342' }

      include_examples 'invalid format'
    end

    context 'when invalid bin' do
      let(:encodable) { '' }
      let(:dec) { '010010abc10101' }

      include_examples 'invalid format'
    end
  end

  context 'with valid input' do
    let(:output) do
      <<~TEXT.strip
        In Miami I saw
        1. A precious body flow and list
        2. A blushing wedding flow and tow
        3. An infantile ice hide and remember
        4. An obese shape join and wail
        5. A next stick know and melt
        6. An easy crew deserve and manufacture
      TEXT
    end

    context 'when str is in hexidecimal format' do
      let(:encodable) do
        <<~TEXT
          da46b559f21b3e955bb1925c964ac5c3b3d72fe1bf37476a104b0e7396027b65
        TEXT
      end

      include_examples 'success'
    end

    context 'when str is in binary format' do
      let(:encodable) do
        <<~TEXT
          1101101001000110101101010101100111110010000110110011111010010101010110111011000110010010010111001001011001001010110001011100001110110011110101110010111111100001101111110011011101000111011010100001000001001011000011100111001110010110000000100111101101100101
        TEXT
      end
      let(:format) { :bin }

      include_examples 'success'
    end

    context 'when str is in decimal format' do
      let(:encodable) do
        <<~TEXT
          98729131926707364344155946614204368554393612909660450514900410658357640330085
        TEXT
      end
      let(:format) { :dec }

      include_examples 'success'
    end
  end
end
