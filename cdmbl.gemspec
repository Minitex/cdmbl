# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cdmbl/version'

Gem::Specification.new do |spec|
  spec.name          = 'cdmbl'
  spec.version       = CDMBL::VERSION
  spec.authors       = ['chadfennell']
  spec.email         = ['fenne035@umn.edu']

  spec.summary       = %q{Use Blacklight (Solr) as a front end for your CONTENTdm instance.}
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'hash_at_path', '~> 0.1'
  spec.add_dependency 'contentdm_api', '~> 0.3.7'
  spec.add_dependency 'sidekiq', '~> 3.5.4'
  spec.add_dependency 'titleize', '~> 1.4'
  spec.add_dependency 'rsolr', '~> 1.0'
  # This gem generally wants to be in a rails app, but just to avoid adding
  # another external dependency for XML procssing, we rely on activesupport's
  # Has.to_xml feature for testing and to allow this gem to function
  # independently from a rails app
  spec.add_dependency 'activesupport', '~> 4.2'

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'yard', '~> 0.9.0'
  spec.add_development_dependency 'webmock', '~> 1.24', '>= 1.24.0'
  spec.add_development_dependency 'vcr', '~> 3.0', '>= 3.0.1'
end
