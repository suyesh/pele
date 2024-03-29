# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "pele/version"

Gem::Specification.new do |spec|
  spec.name          = "pele"
  spec.version       = Pele::VERSION
  spec.authors       = ["Suyesh Bhandari"]
  spec.email         = ["suyeshb@gmail.com"]

  spec.summary       = "Pele lets you deploy multiple servers and run load test"
  spec.description   = "Pele lets you deploy multiple servers and run load test"
  spec.homepage      = "https://github.com/suyesh/pele"

  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry"
  spec.add_dependency 'aws-sdk', '~> 2'
  spec.add_dependency 'thor'
  spec.add_dependency 'os'
  spec.add_dependency 'tty-prompt'
  spec.add_dependency 'colorize'
end
