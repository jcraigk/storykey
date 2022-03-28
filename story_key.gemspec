# frozen_string_literal: true
require_relative 'lib/story_key/version'

Gem::Specification.new do |spec|
  spec.name          = 'story_key'
  spec.version       = StoryKey::VERSION
  spec.authors       = ['Justin Craig-Kuhn (JCK)']
  spec.email         = ['jcraigk@gmail.com']
  spec.summary       = 'StoryKey gives a memorable paragraph in place of your crypto private key'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.1.0'
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport'
  spec.add_dependency 'base58'
  spec.add_dependency 'dry-initializer'
  spec.add_dependency 'indefinite_article'
  spec.add_dependency 'thor'
  spec.add_dependency 'remedy'

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-performance'
  spec.add_development_dependency 'rubocop-rspec'
end
