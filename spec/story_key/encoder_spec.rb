# frozen_string_literal: true
RSpec.describe StoryKey::Encoder do
  subject(:call) { described_class.call(key:, bitsize:, format:) }

  let(:format) { nil }
  let(:bitsize) { nil }

  include_context 'with mocked lexicon'

  shared_examples 'success' do
    it 'returns expected story' do
      expect(call.story).to eq(story)
    end
  end

  shared_examples 'invalid format' do
    it 'raises an exception' do
      expect { call }.to raise_error(StoryKey::InvalidFormat)
    end
  end

  context 'with invalid key' do
    context 'when invalid base58 chars' do
      let(:key) { 'tx\;7ux' }

      include_examples 'invalid format'
    end

    context 'when key is too long' do
      let(:key) do
        <<~TEXT
          2JC4QMFQt7sRSstUmLnhUk6xVNZ24M58C1Hnipo1N72cW3L2gQLMae66UzPJdY1G7Errig4yQzTey5aRsXw1wLw1scnmUs3Vw3SjaNQTmi7zNvheRomp7ZQvVGrN1D3kjK72
        TEXT
      end

      it 'raises an exception' do
        expect { call }.to raise_error(StoryKey::KeyTooLarge)
      end
    end

    context 'when invalid decimal chars' do
      let(:dec) { '34234abc' }
      let(:key) { '' }

      include_examples 'invalid format'
    end

    context 'when invalid bin chars' do
      let(:dec) { '10abc10101' }
      let(:key) { '' }

      include_examples 'invalid format'
    end
  end

  context 'with valid key' do
    let(:story) do
      <<~TEXT.strip
        In #{StoryKey::VERSION_SLUG} I saw an adjective-873 noun-107 verb-342 a noun-499, an adjective-108 noun-1003 verb-343 a noun-947, an adjective-586 noun-458 verb-404 a noun-712, an adjective-784 pre-833 noun-833 verb-462 a noun-999, an adjective-766 pre-889 noun-889 verb-478 a noun-531, an adjective-301 noun-232 verb-229 a pre-518 noun-518, and a noun-496 verb-613 a noun-977.
      TEXT
    end

    context 'when key is in default base58 format' do
      let(:key) { 'Fh4QxGsSAazZWHRogYPMFqLrF4VmXcjhSEtnnVp9eCHJ' }

      include_examples 'success'
    end

    context 'when key is in hexidecimal format' do
      let(:format) { :hex }
      let(:key) { 'da46b559f21b3e955bb1925c964ac5c3b3d72fe1bf37476a104b0e7396027b65' }

      include_examples 'success'
    end

    context 'when key is in binary format' do
      let(:format) { :bin }
      let(:key) do
        <<~TEXT
          1101101001000110101101010101100111110010000110110011111010010101010110111011000110010010010111001001011001001010110001011100001110110011110101110010111111100001101111110011011101000111011010100001000001001011000011100111001110010110000000100111101101100101
        TEXT
      end

      include_examples 'success'
    end

    context 'when key is in decimal format' do
      let(:format) { :dec }
      let(:key) do
        <<~TEXT
          98729131926707364344155946614204368554393612909660450514900410658357640330085
        TEXT
      end

      include_examples 'success'
    end
  end

  context 'with short key' do
    let(:key) { 'da46b55' }
    let(:story) do
      <<~TEXT.strip
        In #{StoryKey::VERSION_SLUG} I saw an adjective-648 noun-285 verb-318 a noun-551, and an adjective-500 noun-257.
      TEXT
    end

    include_examples 'success'
  end

  context 'with 512 bit key producing repeated decimals' do
    let(:format) { :bin }
    let(:key) do
      <<~TEXT.strip
        00000000010000000001000000000100000000010000000001000000000100000000010000000001000000000100000000010000000001000000000100000000010000000001000000000100000000010000000001000000000100000000010000000001000000000100000000010000000001000000000100000000010000000001000000000100000000010000000001000000000100000000010000000001000000000100000000010000000001000000000100000000010000000001000000000100000000010000000001000000000100000000010000000001000000000100000000010000000001000000000100000000010000000001000000000111
      TEXT
    end
    let(:story) do
      <<~TEXT.strip
        In #{StoryKey::VERSION_SLUG} I saw an adjective-1 noun-1 verb-1 a noun-2, an adjective-2 noun-3 verb-2 a noun-4, an adjective-3 noun-5 verb-3 a noun-6, an adjective-4 pre-7 noun-7 verb-4 a noun-8, an adjective-5 noun-9 verb-5 a noun-10, an adjective-6 noun-11 verb-6 a noun-12, an adjective-7 noun-13 verb-7 a pre-14 noun-14, an adjective-8 noun-15 verb-8 a noun-16, an adjective-9 noun-17 verb-9 a noun-18, an adjective-10 noun-19 verb-10 a noun-20, an adjective-11 pre-21 noun-21 verb-11 a noun-22, an adjective-12 noun-23 verb-12 a noun-24, an adjective-13 noun-25 verb-13 a pre-980 noun-980, and a pre-875 noun-875.
      TEXT
    end

    include_examples 'success'
  end

  xcontext 'with hex and bitsize provided, resulting in left padded zeroes' do
  end
end
