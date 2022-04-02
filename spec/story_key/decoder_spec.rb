# frozen_string_literal: true
RSpec.describe StoryKey::Decoder do
  subject(:call) { described_class.new(story:, format:).call }

  let(:format) { nil }

  include_context 'with mocked lexicon'

  shared_examples 'success' do
    it 'returns expected key' do
      expect(call).to eq(key)
    end
  end

  context 'with missing or invalid version lead' do
    let(:story) do
      <<~TEXT.strip
        1. an adjective-873 noun-107 verb-342 a noun-499,
        2. an adjective-108 noun-1003 verb-343 a noun-947,
      TEXT
    end

    it 'raises an exception' do
      expect { call }.to raise_error(StoryKey::InvalidVersion)
    end
  end

  context 'with invalid word(s)' do
    let(:story) do
      <<~TEXT.strip
        In #{StoryKey::VERSION_SLUG} I saw a badword noun-107 verb-343 a noun-905
      TEXT
    end

    it 'raises an exception' do
      expect { call }.to raise_error(StoryKey::InvalidWord)
    end
  end

  context 'with invalid checksum' do
    let(:story) do
      <<~TEXT.strip
        In #{StoryKey::VERSION_SLUG} I saw an adjective-873 noun-107 verb-342 a noun-499, an adjective-108 noun-1003 verb-343 a noun-947, an adjective-586 noun-458 verb-404 a noun-712, an adjective-784 noun-833 verb-462 a noun-999, an adjective-766 noun-889 verb-478 a noun-531, an adjective-301 noun-232 verb-229 a noun-518, and a noun-496 verb-613 a noun-978.
      TEXT
    end

    it 'raises an exception' do
      expect { call }.to raise_error(StoryKey::InvalidChecksum)
    end
  end

  context 'with valid story' do
    let(:story) do
      <<~TEXT.strip
        In #{StoryKey::VERSION_SLUG} I saw an adjective-873 noun-107 verb-342 a noun-499, an adjective-108 noun-1003 verb-343 a noun-947, an adjective-586 noun-458 verb-404 a noun-712, an adjective-784 noun-833 verb-462 a noun-999, an adjective-766 noun-889 verb-478 a noun-531, an adjective-301 noun-232 verb-229 a noun-518, and a noun-496 verb-613 a noun-977.
      TEXT
    end

    context 'when format is hex' do
      let(:key) do
        <<~TEXT.strip
          da46b559f21b3e955bb1925c964ac5c3b3d72fe1bf37476a104b0e7396027b65
        TEXT
      end
      let(:format) { :hex }

      include_examples 'success'
    end

    context 'when format is dec' do
      let(:key) do
        <<~TEXT.strip
          98729131926707364344155946614204368554393612909660450514900410658357640330085
        TEXT
      end
      let(:format) { :dec }

      include_examples 'success'
    end

    context 'when format is bin' do
      let(:key) do
        <<~TEXT.strip
          1101101001000110101101010101100111110010000110110011111010010101010110111011000110010010010111001001011001001010110001011100001110110011110101110010111111100001101111110011011101000111011010100001000001001011000011100111001110010110000000100111101101100101
        TEXT
      end
      let(:format) { :bin }

      include_examples 'success'
    end
  end
end
