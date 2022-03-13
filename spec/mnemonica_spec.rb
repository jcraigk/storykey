# frozen_string_literal: true

RSpec.describe Mnemonica do
  it 'has a version number' do
    expect(Mnemonica::VERSION).not_to be_nil
  end

  describe '#encode' do
    let(:str) { 'abcd1234' }
    let(:mock_encoder) { instance_spy(Mnemonica::Encoder) }

    before do
      allow(Mnemonica::Encoder).to receive(:new).with(str).and_return(mock_encoder)
      allow(mock_encoder).to receive(:call)
      described_class.encode(str)
    end

    it 'calls Mnemonica::Encoder' do
      expect(mock_encoder).to have_received(:call)
    end
  end
end
