class StoryKey::Tokenizer < StoryKey::Base
  param :text

  def call
    token_from_text
  end

  private

  def token_from_text
    text.downcase
        .gsub(/\[.+\]/, "")
        .gsub(/[^a-z0-9\s-]/, "")
        .strip
        .gsub(/\s+/, "-")
  end
end
