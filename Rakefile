require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "light_mongo"
    gem.summary = %Q{A lightweight Ruby object persistence library for Mongo DB}
    gem.description = %Q{LightMongo is a lightweight Mongo object persistence layer for Ruby which makes use of Mongo's features rather than trying to emulate ActiveRecord.}
    gem.email = "elliotcm@googlemail.com"
    gem.homepage = "http://github.com/elliotcm/light_mongo"
    gem.authors = ["Elliot Crosby-McCullough"]
    gem.add_development_dependency "rspec", ">= 1.3.0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec
