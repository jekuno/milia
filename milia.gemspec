# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'milia/version'

Gem::Specification.new do |spec|
  spec.name          = "milia"
  spec.version       = Milia::VERSION
  spec.authors       = ["daudi amani"]
  spec.email         = ["dsaronin@gmail.com"]
  spec.description   = %q{Multi-tenanting gem for hosted Rails/Ruby/devise applications}
  spec.summary       = %q{Transparent multi-tenanting for hosted rails/ruby/devise web applications}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'rails', '~> 4.2'
  spec.add_dependency 'devise', '~> 3.4'

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "shoulda"
  spec.add_development_dependency "turn"
end
