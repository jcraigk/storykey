# frozen_string_literal: true

RSpec.describe Peartree::Tokenizer do
  subject(:call) { described_class.call(str) }

  shared_examples 'success' do
    it 'returns expected token' do
      expect(call).to eq(token)
    end
  end

  context 'with simple word' do
    let(:str) { 'apple' }
    let(:token) { 'apple' }

    include_examples 'success'
  end

  context 'with titleized word' do
    let(:str) { 'Apple' }
    let(:token) { 'apple' }

    include_examples 'success'
  end

  context 'with multiple words' do
    let(:str) { 'Steve Apple' }
    let(:token) { 'steveapple' }

    include_examples 'success'
  end

  context 'with a preposition' do
    let(:str) { 'look [at]' }
    let(:token) { 'look' }

    include_examples 'success'
  end
end
