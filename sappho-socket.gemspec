# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'sappho-socket/version'

# See http://docs.rubygems.org/read/chapter/20#page85 for info on writing gemspecs

Gem::Specification.new do |s|
  s.name        = Sappho::Socket::NAME
  s.version     = Sappho::Socket::VERSION
  s.authors     = Sappho::Socket::AUTHORS
  s.email       = Sappho::Socket::EMAILS
  s.homepage    = Sappho::Socket::HOMEPAGE
  s.summary     = Sappho::Socket::SUMMARY
  s.description = Sappho::Socket::DESCRIPTION

  s.rubyforge_project = Sappho::Socket::NAME

  s.files         = Dir['lib/**/*']
  s.test_files    = Dir['test/**/*']
  s.executables   = Dir['bin/*'].map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
  s.add_development_dependency 'rake', '>= 0.9.2.2'
end
