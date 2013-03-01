require 'bundler'
require 'bundler/version'

require File.expand_path('lib/createsend/version')

Gem::Specification.new do |s|
  s.add_development_dependency('rake', '~> 10.0')
  s.add_development_dependency('fakeweb', '~> 1.3')
  s.add_development_dependency('jnunemaker-matchy', '~> 0.4')
  s.add_development_dependency('shoulda', '~> 3.3')
  s.add_runtime_dependency('json', '>= 0')
  s.add_runtime_dependency('hashie', '~> 2.0')
  s.add_runtime_dependency('httparty', '~> 0.10')
  s.name = "createsend"
  s.author = "James Dennes"
  s.description = %q{Implements the complete functionality of the Campaign Monitor API.}
  s.email = ["jdennes@gmail.com"]
  s.executables = `git ls-files -- bin/*`.split("\n").map{|f| File.basename(f)}
  s.files = `git ls-files`.split("\n")
  s.homepage = "http://campaignmonitor.github.com/createsend-ruby/"
  s.require_paths = ["lib"]
  s.summary = %q{A library which implements the complete functionality of the Campaign Monitor API.}
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.version = CreateSend::VERSION
  s.platform = Gem::Platform::RUBY
  s.required_rubygems_version = Gem::Requirement.new('>= 1.3.6') if s.respond_to? :required_rubygems_version=
end
