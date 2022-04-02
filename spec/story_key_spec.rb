# frozen_string_literal: true
RSpec.describe StoryKey do
  it 'has a version number' do
    expect(StoryKey::VERSION).not_to be_nil
  end

  it 'has a version slug' do
    expect(StoryKey::VERSION_SLUG).to match(/\A[A-Za-z]{1,10}\Z/)
  end

  it 'has a lexicon slug' do
    expect(StoryKey::LEXICON_SHA.size).to eq(StoryKey::LEXICON_SHA_SIZE)
  end
end
