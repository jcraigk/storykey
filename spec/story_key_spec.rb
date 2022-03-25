# frozen_string_literal: true
RSpec.describe StoryKey do
  it 'has a version number' do
    expect(StoryKey::VERSION).not_to be_nil
  end
end
