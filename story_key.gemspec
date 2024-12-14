require_relative "lib/story_key/version"

Gem::Specification.new do |spec|
  spec.name          = "story_key"
  spec.version       = StoryKey::VERSION
  spec.authors       = [ "Justin Craig-Kuhn (JCK)" ]
  spec.email         = [ "jcraigk@gmail.com" ]
  spec.summary       = "StoryKey converts a private key to a memorable story and vice versa."
  spec.homepage      = "https://github.com/jcraigk/storykey"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.2.0"
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{\Abin/}) { |f| File.basename(f) }
  spec.require_paths = [ "lib" ]
  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(spec)/})
  end

  spec.add_dependency "activesupport", "~> 8.0.1"
  spec.add_dependency "awesome_print", "~> 1.9.2"
  spec.add_dependency "base58", "~> 0.2.3"
  spec.add_dependency "dotenv", "~> 3.1.6"
  spec.add_dependency "dry-initializer", "~> 3.1.1"
  spec.add_dependency "indefinite_article", "~> 0.2.5"
  spec.add_dependency "remedy", "~> 0.4.0"
  spec.add_dependency "rmagick", "~> 6.0.1"
  spec.add_dependency "thor", "~> 1.3.2"
  spec.add_dependency "typhoeus", "~> 1.4.1"
  spec.add_dependency "zeitwerk", "~> 2.7.1"

  spec.add_development_dependency "bundler", "~> 2.5.23"
  spec.add_development_dependency "rake", "~> 13.2.1"
  spec.add_development_dependency "rspec", "~> 3.13.0"
  spec.add_development_dependency "rubocop", "~> 1.69.2"
  spec.add_development_dependency "rubocop-performance", "~> 1.23.0"
  spec.add_development_dependency "rubocop-rake", "~> 0.6.0"
  spec.add_development_dependency "rubocop-rspec", "~> 3.3.0"
  spec.add_development_dependency "rubocop-rails-omakase", "~> 1.0.0"
end
