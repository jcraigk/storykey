RSpec.describe StoryKey::KeyGenerator do
  subject(:call) { described_class.new(bitsize:, format:).call }

  let(:bitsize) { StoryKey::DEFAULT_BITSIZE }
  let(:format) { :bin }

  it 'generates a binary string' do
    expect(call).to match(/[01]{256}/)
  end
end
