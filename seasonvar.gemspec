# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'seasonvar/version'

Gem::Specification.new do |spec|
  spec.name          = 'seasonvar'
  spec.version       = Seasonvar::VERSION
  spec.authors       = ['Sergey Avseyev']
  spec.email         = ['sergey.avseyev@gmail.com']

  spec.summary       = 'Client for seasonvar.ru API'
  spec.description   = 'The library which allows to work with API of series aggregator seasonvar.ru'
  spec.homepage      = 'https://github.com/avsej/seasonvar.rb'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'faraday', '~> 0.9.0'
  spec.add_runtime_dependency 'net-http-persistent', '~> 2.9'
  spec.add_runtime_dependency 'json', '~> 1.8'

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
end
