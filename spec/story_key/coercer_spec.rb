# frozen_string_literal: true

RSpec.describe StoryKey::Coercer do
  subject(:call) { described_class.call(str:, bitsize:, input:, output:) }

  let(:bitsize) { 256 }
  let(:bin) do
    <<~TEXT.strip
      0101101001000110101101010101100111110010000110110011111010010101010110111011000110010010010111001001011001001010110001011100001110110011110101110010111111100001101111110011011101000111011010100001000001001011000011100111001110010110000000100111101101100101
    TEXT
  end
  let(:dec) { '40833087308049266632370454109860414627758620576840168495171618654401075510117' }
  let(:hex) { '5a46b559f21b3e955bb1925c964ac5c3b3d72fe1bf37476a104b0e7396027b65' }
  let(:base58) { '75QECszdmZdBDk36ZxJCfDwb7pB7A1hehDR8MY6mPDfA' }

  shared_examples 'success' do
    context 'when output is :bin' do
      let(:output) { :bin }
      let(:expected) { bin }

      it 'returns expected value' do
        expect(call).to eq(expected)
      end
    end

    context 'when output is :dec' do
      let(:output) { :dec }
      let(:expected) { dec }

      it 'returns expected value' do
        expect(call).to eq(expected)
      end
    end

    context 'when output is :hex' do
      let(:output) { :hex }
      let(:expected) { hex }

      it 'returns expected value' do
        expect(call).to eq(expected)
      end
    end

    context 'when output is :base58' do
      let(:output) { :base58 }
      let(:expected) { base58 }

      it 'returns expected value' do
        expect(call).to eq(expected)
      end
    end
  end

  context 'when input is :bin' do
    let(:input) { :bin }
    let(:str) { bin }

    include_examples 'success'
  end

  context 'when input is :dec' do
    let(:input) { :dec }
    let(:str) { dec }

    include_examples 'success'
  end

  context 'when input is :hex' do
    let(:input) { :hex }
    let(:str) { hex }

    include_examples 'success'
  end

  context 'when input is :base58' do
    let(:input) { :base58 }
    let(:str) { base58 }

    include_examples 'success'
  end
end
