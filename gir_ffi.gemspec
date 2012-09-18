# -*- encoding: utf-8 -*-
require File.join(File.dirname(__FILE__), 'lib/gir_ffi/version.rb')

Gem::Specification.new do |s|
  s.name = "gir_ffi"
  s.version = GirFFI::VERSION

  s.summary = "FFI-based GObject binding using the GObject Introspection Repository"

  s.authors = ["Matijs van Zuijlen"]
  s.email = ["matijs@matijs.net"]
  s.homepage = "http://www.github.com/mvz/ruby-gir-ffi"

  s.rdoc_options = ["--main", "README.md"]

  s.files = Dir[ '{lib,test,tasks,examples}/**/*',
                 "*.md",
                 "*.rdoc",
                 "History.txt",
                 "Rakefile",
                 "COPYING.LIB" ] & `git ls-files -z`.split("\0")

  s.extra_rdoc_files = ["DESIGN.rdoc", "History.txt", "README.md", "TODO.rdoc"]
  s.test_files = `git ls-files -z -- test`.split("\0")

  s.add_runtime_dependency(%q<ffi>, ["~> 1.0.8"])
  s.add_runtime_dependency(%q<indentation>, ["~> 0.0.6"])

  s.add_development_dependency('minitest', [">= 2.0.2"])
  s.add_development_dependency('rr', ["~> 1.0.2"])
  s.add_development_dependency('rake', ["~> 0.9.2"])

  s.require_paths = ["lib"]
end
