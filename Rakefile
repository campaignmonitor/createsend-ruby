$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "bundler/version"
require "rake/testtask"
require "./lib/createsend"

desc "Run tests"
Rake::TestTask.new(:test) do |test|
  test.ruby_opts = ["-rubygems"] if defined? Gem
  test.libs << "lib" << "test"
  test.pattern = "test/**/*_test.rb"
  puts "running tests."
end

desc "Build the gem"
task :build do
  system "gem build createsend.gemspec"
end

desc "Build and release the gem"
task :release => :build do
  system "gem push createsend-#{CreateSend::VERSION}.gem"
end

task :default => :test
