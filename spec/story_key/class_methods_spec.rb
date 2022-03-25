# frozen_string_literal: true
class TestClass
  extend StoryKey::ClassMethods
end

RSpec.describe TestClass do # rubocop:disable RSpec/FilePath
  describe '#encode' do
    let(:key) { 'abcd1234' }
    let(:mock_encoder) { instance_spy(StoryKey::Encoder) }

    before do
      allow(StoryKey::Encoder).to receive(:new).with(key:).and_return(mock_encoder)
      allow(mock_encoder).to receive(:call)
      described_class.encode(key:)
    end

    it 'calls StoryKey::Encoder' do
      expect(mock_encoder).to have_received(:call)
    end
  end

  describe '#decode' do
    let(:story) { 'some phrase ...' }
    let(:mock_decoder) { instance_spy(StoryKey::Decoder) }

    before do
      allow(StoryKey::Decoder).to receive(:new).with(story:).and_return(mock_decoder)
      allow(mock_decoder).to receive(:call)
      described_class.decode(story:)
    end

    it 'calls StoryKey::Decoder' do
      expect(mock_decoder).to have_received(:call)
    end
  end

  xdescribe '#generate' do
  end
end
