# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'configrr/version'

Gem::Specification.new do |s|
  s.name          = 'configrr'
  s.version       = Configrr::VERSION
  s.platform      = Gem::Platform::RUBY
  s.summary       = "Output app configs from various input sources and templates."
  s.description   = "Using input sources like Foreman and Consul generate app specific configs using ERB templates. "
  s.author        = "AJ"
  s.email         = "ajambu@collectivei.com"
  s.homepage      = "https://git.ccmteam.com/projects/SM/repos/configrr"
  s.files         = Dir['README.md', '{bin,lib}/**/*']
  s.require_paths = ['lib']

  s.license       = "MIT"

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }

  s.add_dependency('cri', '~> 2.7')
  s.add_dependency('faraday', '< 1.0')
  s.add_dependency('activesupport', '~> 4.0')
end
