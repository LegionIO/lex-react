# frozen_string_literal: true

require_relative 'lib/legion/extensions/react/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-react'
  spec.version       = Legion::Extensions::React::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['legionio@esity.com']
  spec.summary       = 'Reaction engine for LegionIO'
  spec.description   = 'Event-driven automation rules that subscribe to Legion::Events and fire configurable reaction chains'
  spec.homepage      = 'https://github.com/LegionIO/lex-react'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.files         = Dir['lib/**/*', 'README.md', 'CHANGELOG.md']
  spec.require_paths = ['lib']

  spec.metadata['rubygems_mfa_required'] = 'true'
end
