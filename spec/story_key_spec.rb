# frozen_string_literal: true

RSpec.describe StoryKey do
  it 'has a version number' do
    expect(StoryKey::VERSION).not_to be_nil
  end

  describe '#encode' do
    let(:str) { 'abcd1234' }
    let(:mock_encoder) { instance_spy(StoryKey::Encoder) }

    before do
      allow(StoryKey::Encoder).to receive(:new).with(str:, format: nil).and_return(mock_encoder)
      allow(mock_encoder).to receive(:call)
      described_class.encode(str:)
    end

    it 'calls StoryKey::Encoder' do
      expect(mock_encoder).to have_received(:call)
    end
  end

  describe '#decode' do
    let(:str) { 'some phrase ...' }
    let(:mock_decoder) { instance_spy(StoryKey::Decoder) }

    before do
      allow(StoryKey::Decoder).to receive(:new).with(str:, format: nil).and_return(mock_decoder)
      allow(mock_decoder).to receive(:call)
      described_class.decode(str:)
    end

    it 'calls StoryKey::Decoder' do
      expect(mock_decoder).to have_received(:call)
    end
  end

  xdescribe '#generate' do
  end
end
