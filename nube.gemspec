# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nube/version'

Gem::Specification.new do |spec|
  spec.name          = "nube"
  spec.version       = Nube::VERSION
  spec.authors       = ["g.edera", "eserdio"]
  spec.email         = ["gab.edera@gmail.com"]

  spec.summary       = %q{It's possible work with object in differents rails aplicacion as activerecord. All relation, scopes, validations for activerecord works with remote objects}
  spec.description   = %q{Working with remote objects as activerecord}
  spec.homepage      = "https://github.com/gedera/nube.git"
  spec.license       = "MIT"
  spec.required_ruby_version = '>= 1.8.6'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency('actionpack',   '~> 5.x')
  spec.add_dependency('activesupport', '~> 5.x')
  # spec.add_dependency('activemodel',   '~> 4.x')
  spec.add_dependency("railties", "~> 5.x")

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 11.2"
  # spec.add_development_dependency "rspec", "~> 3.0"
end
