# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'milia/version'

Gem::Specification.new do |spec|
  spec.name          = "milia"
  spec.version       = Milia::VERSION
  spec.authors       = ["dsaronin", "jekuno"]
  spec.email         = ["jekuno@users.noreply.github.com"]
  spec.homepage      = "https://github.com/jekuno/milia"
  spec.summary       = "Easy multi-tenanting for Rails + Devise"
  spec.description   = "Transparent multi-tenanting for web applications based on Rails and Devise"
  spec.license       = "MIT"

  spec.files         = `git ls-files app lib`.split("\n")
  spec.platform      = Gem::Platform::RUBY
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'rails', '~> 5.0'
  spec.add_runtime_dependency 'devise', '~> 4.2'

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "shoulda", '~> 3.5'
  spec.add_development_dependency "turn", "~> 0.9"
end
