# frozen_string_literal: true
RSpec.describe StoryKey::Console do
  subject(:console) { described_class }

  let(:result) { console.invoke(:new) }

  xit 'generates a new key/story' do
    # expect(console.shell).to have_received(:new)
  end
end
