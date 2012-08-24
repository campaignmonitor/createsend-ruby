$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "bundler/version"
require "rake/testtask"
require "./lib/createsend"

begin
  if RUBY_VERSION != "1.8.7" # cane not supported on < 1.8.7
    require 'cane/rake_task'

    desc "Run cane (checks quality metrics)"
    Cane::RakeTask.new(:quality) do |cane|
      cane.abc_glob = '{lib,test}/**/*.rb'
      cane.abc_max = 10
      puts "running cane."
    end

    task :default => :quality
  end
rescue LoadError
  warn "cane not available, quality task not provided."
end

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
