# frozen_string_literal: true

RSpec.describe StoryKey::Encoder do
  subject(:call) { described_class.call(input, format:) }

  let(:format) { nil }

  include_context 'with mocked lexicon'

  shared_examples 'success' do
    it 'returns expected text' do
      expect(call.text).to eq(text)
    end
  end

  shared_examples 'invalid format' do
    it 'raises an exception' do
      expect { call }.to raise_error(StoryKey::InvalidFormat)
    end
  end

  context 'with invalid input' do
    context 'when invalid hex chars' do
      let(:input) { '23az939fs2' }

      include_examples 'invalid format'
    end

    context 'when input is too long' do
      let(:input) do
        <<~TEXT
          da46b559f21b3e955bb1925c964ac5c3b3d72fe1bf37476a104b0e7396027b65da46b559f21b3e955bb1925c964ac5c3b3d72fe1bf37476a104b0e7396027b65da46b559f21b3e955bb1925c964ac5c3b3d72fe1bf37476a104b0e7396027b65
        TEXT
      end

      it 'raises an exception' do
        expect { call }.to raise_error(StoryKey::InputTooLarge)
      end
    end

    context 'when invalid decimal chars' do
      let(:dec) { '34234abc2342' }
      let(:input) { '' }

      include_examples 'invalid format'
    end

    context 'when invalid bin chars' do
      let(:dec) { '010010abc10101' }
      let(:input) { '' }

      include_examples 'invalid format'
    end
  end

  context 'with valid input' do
    let(:text) do
      <<~TEXT.strip
        In #{StoryKey::VERSION_SLUG} I saw
        1. an adjective-873 noun-107 verb-342 a noun-499,
        2. an adjective-108 noun-1003 verb-343 a noun-947,
        3. an adjective-586 noun-458 verb-404 a noun-712,
        4. an adjective-784 pre-833 noun-833 verb-462 a noun-999,
        5. an adjective-766 pre-889 noun-889 verb-478 a noun-531,
        6. an adjective-301 noun-232 verb-229 a pre-518 noun-518,
        7. and a noun-496 verb-613 a noun-977
      TEXT
    end

    context 'when input is in hexidecimal format' do
      let(:input) do
        <<~TEXT
          da46b559f21b3e955bb1925c964ac5c3b3d72fe1bf37476a104b0e7396027b65
        TEXT
      end

      include_examples 'success'
    end

    context 'when input is in binary format' do
      let(:format) { :bin }
      let(:input) do
        <<~TEXT
          1101101001000110101101010101100111110010000110110011111010010101010110111011000110010010010111001001011001001010110001011100001110110011110101110010111111100001101111110011011101000111011010100001000001001011000011100111001110010110000000100111101101100101
        TEXT
      end

      include_examples 'success'
    end

    context 'when input is in decimal format' do
      let(:format) { :dec }
      let(:input) do
        <<~TEXT
          98729131926707364344155946614204368554393612909660450514900410658357640330085
        TEXT
      end

      include_examples 'success'
    end
  end

  context 'with short input and partial last phrase' do
    let(:input) { 'da46b55' }
    let(:text) do
      <<~TEXT.strip
        In #{StoryKey::VERSION_SLUG} I saw an adjective-873 noun-107 verb-343 a noun-905
      TEXT
    end

    include_examples 'success'
  end

  context 'when last segment is not default size' do
    let(:input) { '3ff' }
    let(:text) do
      <<~TEXT.strip
        In #{StoryKey::VERSION_SLUG} I saw a noun-1023 verb-843 a noun-256
      TEXT
    end

    include_examples 'success'
  end

  context 'with large input producing repeated decimals' do
    let(:format) { :bin }
    let(:input) do
      <<~TEXT.strip
        00000000010000000001000000000100000000010000000001000000000100000000010000000001000000000100000000010000000001000000000100000000010000000001000000000100000000010000000001000000000100000000010000000001000000000100000000010000000001000000000100000000010000000000000001000000000100000000010000000001000000000100000000010000000001000000000100000000010000000001000000000100000000010000000001000000000100000000010000000001000000000100000000010000000001000000000100000000010000000001000000000100000000010000000001000000
      TEXT
    end
    let(:text) do
      <<~TEXT.strip
        In #{StoryKey::VERSION_SLUG} I saw
        1. an adjective-1 noun-1 verb-1 a noun-2,
        2. an adjective-2 noun-3 verb-2 a noun-4,
        3. an adjective-3 noun-5 verb-3 a noun-6,
        4. an adjective-4 pre-7 noun-7 verb-4 a noun-8,
        5. an adjective-5 noun-9 verb-5 a noun-10,
        6. an adjective-6 noun-11 verb-6 a noun-12,
        7. an adjective-7 pre-0 noun-0 verb-22 a noun-29,
        8. an adjective-23 noun-30 verb-23 a noun-31,
        9. an adjective-24 noun-32 verb-24 a noun-33,
        10. an adjective-25 noun-34 verb-25 a pre-35 noun-35,
        11. an adjective-26 noun-36 verb-26 a noun-37,
        12. an adjective-27 noun-38 verb-27 a noun-39,
        13. an adjective-28 noun-40 verb-28 a noun-167,
        14. and a noun-15
      TEXT
    end

    include_examples 'success'
  end
end
