# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'heatapp/version'

Gem::Specification.new do |spec|
  spec.name          = 'heatapp'
  spec.version       = Heatapp::VERSION
  spec.authors       = ['Markus Frosch']
  spec.email         = ['markus@lazyfrosch.de']

  spec.summary       = 'Communicate with the Heatapp Base'
  spec.description   = 'Heatapp is a heating control system for radiators and floor heating.'\
                       ' This gem wants to provide you a programmatic interface to the base.'
  spec.homepage      = 'https://github.com/lazyfrosch/ruby-heatapp'
  spec.license       = 'GPL-2+'

  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'rest-client', '>= 2.0'

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake',    '~> 10.0'
  spec.add_development_dependency 'rspec',   '~> 3.0'
  spec.add_development_dependency 'webmock', '~> 2.1.0'
end
