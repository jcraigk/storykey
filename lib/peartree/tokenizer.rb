# frozen_string_literal: true
class Peartree::Tokenizer < Peartree::Base
  param :text

  SIZE = 13 # TODO: get this down to 4 or 5

  def call
    token_from_text
  end

  private

  def token_from_text
    text.downcase
        .gsub(/\[.+\]/, '')
        .gsub(/[^a-z0-9]/, '')[0..(SIZE - 1)]
  end
end
