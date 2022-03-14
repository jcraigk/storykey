# frozen_string_literal: true

RSpec.describe Mnemonica::Encoder do
  subject(:call) { described_class.new(encodable, format:).call }

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

  shared_examples 'invalid format' do
    it 'raises an exception' do
      expect { call }.to raise_error(Mnemonica::InvalidFormat)
    end
  end
  #
  # context 'with invalid input' do
  #   context 'when invalid hex' do
  #     let(:encodable) { '23az939fs2' }
  #
  #     include_examples 'invalid format'
  #   end
  #
  #   context 'when invalid decimal' do
  #     let(:encodable) { '' }
  #     let(:dec) { '34234abc2342' }
  #
  #     include_examples 'invalid format'
  #   end
  #
  #   context 'when invalid bin' do
  #     let(:encodable) { '' }
  #     let(:dec) { '010010abc10101' }
  #
  #     include_examples 'invalid format'
  #   end
  # end

  context 'with valid input' do
    let(:output) do
      <<~TEXT.strip
        In #{Mnemonica::VERSION_SLUG} at 6pm I saw
        1. An adjective873 noun107 verb342 and verb498
        2. An adjective108 noun1001 verb342 and verb945
        3. An adjective585 noun457 verb402 and verb709
        4. An adjective782 noun829 verb459 and verb993
        5. An adjective764 noun884 verb474 and verb528
        6. An adjective300 noun231 verb229 and verb514
        7. An adjective493 noun37
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
