# frozen_string_literal: true

RSpec.describe Mnemonica::Decoder do
  subject(:call) { described_class.new(input).call }

  context 'with input missing version slug' do
    let(:input) do
      <<~TEXT
        1. A previous hand sting and transform
        2. A scratchy historian lecture and rob
      TEXT
    end

    it 'raises an exception' do
      expect { call }.to raise_error(Mnemonica::InvalidVersion)
    end
  end

  context 'when input is complete and valid' do
    let(:input) do
      <<~TEXT.strip
        In Miami I saw
        1. A previous hand sting and transform
        2. A scratchy historian lecture and rob
        3. A remote girl direct and suck
        4. A silky youth snow and rate
        5. A genuine union grip and attract
      TEXT
    end
    let(:output) do
      'da46b559f21b3e955bb1925c964ac5c3b3d72fe1bf37476a104b0e7396027b65'
    end

    it 'returns expected output' do
      expect(call).to eq(output)
    end
  end
end
