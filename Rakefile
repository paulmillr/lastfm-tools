# encoding: utf-8
require 'bundler'
require 'jeweler'
require 'rake'
require 'rdoc/task'
require 'rspec/core'
require 'rspec/core/rake_task'
require 'rubygems'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

Jeweler::Tasks.new do |gem|
  gem.name = "lastfm_tools"
  gem.summary = "Last.FM backuper, helper and data analyzer."
  gem.description = "A backuper, helper and data analyzer for Last.fm API 2.0"
  gem.email = "paul@paulmillr.com"
  gem.homepage = "http://github.com/paulmillr/lastfm_tools"
  gem.authors = ["paulmillr"]
end

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task :default => :spec

Rake::RDocTask.new do |rdoc|
  version = File.read('VERSION')

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "lastfm_tools #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
