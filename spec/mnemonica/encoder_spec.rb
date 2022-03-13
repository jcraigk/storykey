# frozen_string_literal: true

RSpec.describe Mnemonica::Encoder do
  subject(:call) { described_class.new(str).call }

  context 'when str is not in hexidecimal format' do
    let(:str) { 'not-hex' }

    it 'raises InvalidFormat' do
      expect { call }.to raise_error(Mnemonica::InvalidFormat)
    end
  end

  context 'when str is in hexidecimal format' do
    let(:str) { 'da46b559f21b3e955bb1925c964ac5c3b3d72fe1bf37476a104b0e7396027b65' }
    let(:phrase) { '...' }

    it 'returns a phrase' do
      expect(call).to eq(phrase)
    end
  end
end
