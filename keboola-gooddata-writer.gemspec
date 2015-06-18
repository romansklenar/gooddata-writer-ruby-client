# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'keboola/gooddata_writer/version'

Gem::Specification.new do |spec|
  spec.name          = "keboola-gooddata-writer"
  spec.version       = Keboola::GoodDataWriter::VERSION
  spec.authors       = ["Roman Sklenář"]
  spec.email         = ["mail@romansklenar.cz"]

  spec.summary       = "A convenient Ruby wrapper around the Keboola GoodData Writer API."
  spec.description   = "Use the Keboola::GoodDataWriter class to integrate Keboola GoodData Writer into your own application."
  spec.homepage      = "https://github.com/romansklenar/gooddata-writer-ruby-client"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.7"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "vcr", "~> 2.9"

  spec.add_dependency "json"
  spec.add_dependency "hurley", "~> 0.1"
end
