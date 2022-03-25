# frozen_string_literal: true
RSpec.describe 'integration' do
  let(:bitsize) { nil }
  let(:format) { nil }
  let(:encoded) { StoryKey.encode(key:, bitsize:, format:) }
  let(:output) { StoryKey.decode(story: encoded.story, format:) }

  shared_examples 'success' do
    it 'encodes and decodes the key successfully' do
      expect(output).to eq(key)
    end
  end

  context 'with invalid key' do
    let(:key) { '-' }

    it 'raises an exception' do
      expect { encoded }.to raise_error(StoryKey::InvalidFormat)
    end
  end

  context 'with single bit, no bitsize/format specified' do
    let(:key) { '1' }

    include_examples 'success'
  end

  context 'with small hex input' do
    let(:key) { 'da46b55' }
    let(:format) { :hex }

    include_examples 'success'
  end

  context 'with 256-bit base58' do
    let(:key) { 'Fh4QxGsSAazZWHRogYPMFqLrF4VmXcjhSEtnnVp9eCHJ' }
    let(:bitsize) { 256 }

    include_examples 'success'
  end
end
