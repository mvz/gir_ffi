# -*- encoding: utf-8 -*-
require File.join(File.dirname(__FILE__), 'lib/gir_ffi/version.rb')

Gem::Specification.new do |s|
  s.name = "gir_ffi"
  s.version = GirFFI::VERSION

  s.summary = "FFI-based GObject binding using the GObject Introspection Repository"
  s.required_ruby_version = %q{>= 1.9.3}

  s.authors = ["Matijs van Zuijlen"]
  s.email = ["matijs@matijs.net"]
  s.homepage = "http://www.github.com/mvz/ruby-gir-ffi"

  s.license = 'LGPL-2.1'

  s.description = <<-DESC
    GirFFI creates bindings for GObject-based libraries at runtime based on introspection
    data provided by the GObject Introspection Repository (GIR) system. Bindings are created
    at runtime and use FFI to interface with the C libraries. In cases where the GIR does not
    provide enough or correct information to create sane bindings, overrides may be created.
  DESC

  s.files = Dir[ '{lib,test,tasks,examples}/**/*',
                 "*.md",
                 "*.gemspec",
                 "Rakefile",
                 "COPYING.LIB" ] & `git ls-files -z`.split("\0")

  s.rdoc_options = ["--main", "README.md"]
  s.extra_rdoc_files = ["DESIGN.md", "Changelog.md", "README.md", "TODO.md"]

  s.add_runtime_dependency('ffi', ["~> 1.8"])
  s.add_runtime_dependency('indentation', ["~> 0.1.1"])

  s.add_development_dependency('minitest', ["~> 5.5.1"])
  s.add_development_dependency('minitest-rspec_mocks', ["~> 0.2.0"])
  s.add_development_dependency('rake', ["~> 10.1"])

  s.require_paths = ["lib"]
end
