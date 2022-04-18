# frozen_string_literal: true
require_relative 'lib/story_key/version'

Gem::Specification.new do |spec|
  spec.name          = 'story_key'
  spec.version       = StoryKey::VERSION
  spec.authors       = ['Justin Craig-Kuhn (JCK)']
  spec.email         = ['jcraigk@gmail.com']
  spec.summary       = 'StoryKey turns your crypto private key into a memorable story'
  spec.homepage      = 'https://github.com/jcraigk/story_key'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.1.0'
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{\Abin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(spec)/})
  end

  spec.add_dependency 'activesupport', '~> 7.0.2'
  spec.add_dependency 'awesome_print', '~> 1.9.2'
  spec.add_dependency 'base58', '~> 0.2.3'
  spec.add_dependency 'dry-initializer', '~> 3.1.1'
  spec.add_dependency 'indefinite_article', '~> 0.2.4'
  spec.add_dependency 'pry', '~> 0.14.1'
  spec.add_dependency 'remedy', '~> 0.3.0'
  spec.add_dependency 'thor', '~> 1.2.1'
  spec.add_dependency 'zeitwerk', '~> 2.5.4'

  spec.add_development_dependency 'bundler', '~> 2.3.11'
  spec.add_development_dependency 'rake', '~> 13.0.6'
  spec.add_development_dependency 'rspec', '~> 3.11.0'
  spec.add_development_dependency 'rubocop', '~> 1.27.0'
  spec.add_development_dependency 'rubocop-performance', '~> 1.13.3'
  spec.add_development_dependency 'rubocop-rake', '~> 0.6.0'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.9.0'
end
