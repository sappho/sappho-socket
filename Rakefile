require "bundler/gem_tasks"
require 'rake/testtask'

task :default => :test
task :install => :test
task :release => :test

Rake::TestTask.new(:test) do |t|
  t.libs << 'test/ruby'
  t.pattern = 'test/ruby/**/*_test.rb'
  t.verbose = true
end
