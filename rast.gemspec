# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'rast'
  spec.version       = '0.1.2.pre'
  spec.authors       = ['Royce Remulla']
  spec.email         = ['royce.com@gmail.com']

  spec.summary       = 'RSpec AST - All Scenario Testing'
  spec.description   = 'Extends RSpec functionality by using the catch-all-scenario testing (CAST) principle.'
  spec.homepage      = 'https://github.com/roycetech/rast'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('~> 2.0')

  # spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/roycetech/rast'
  spec.metadata['changelog_uri'] = 'https://github.com/roycetech/rast/blob/feature/ruby-2.0.0-support/CHANGELOG.md'

  spec.files = Dir.chdir(File.expand_path('.')) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = %w[lib]
end
