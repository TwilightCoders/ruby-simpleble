require_relative 'lib/simpleble/version'

Gem::Specification.new do |spec|
  spec.name          = 'simpleble'
  spec.version       = SimpleBLE::VERSION
  spec.authors       = ['Dale Stevens']
  spec.email         = ['dale@twilightcoders.net']

  spec.summary       = 'Cross-platform Bluetooth Low Energy library for Ruby'
  spec.description   = 'Ruby bindings for the SimpleBLE C library, providing enterprise-grade cross-platform BLE functionality for scanning, connecting, and interacting with Bluetooth Low Energy devices.'
  spec.homepage      = 'https://github.com/twilightcoders/ruby-simpleble'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = "#{spec.homepage}.git"
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['documentation_uri'] = spec.homepage
  spec.metadata['bug_tracker_uri'] = "#{spec.homepage}/issues"
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  spec.files         = Dir['CHANGELOG.md', 'README.md', 'LICENSE.txt', 'lib/**/*', 'bin/*', 'ext/**/*'] +
                       Dir['vendor/simpleble/**/{*.c,*.h,*.cpp,*.hpp}']
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.extensions    = ['ext/simpleble/extconf.rb']

  # Development dependencies
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rake-compiler', '~> 1.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
