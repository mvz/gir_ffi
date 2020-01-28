# frozen_string_literal: true

require File.join(File.dirname(__FILE__), "lib/gir_ffi/version.rb")

Gem::Specification.new do |s|
  s.name = "gir_ffi"
  s.version = GirFFI::VERSION

  s.summary = "FFI-based GObject binding using the GObject Introspection Repository"
  s.required_ruby_version = ">= 2.4.0"

  s.authors = ["Matijs van Zuijlen"]
  s.email = ["matijs@matijs.net"]
  s.homepage = "http://www.github.com/mvz/ruby-gir-ffi"

  s.license = "LGPL-2.1+"

  s.description = <<-DESC
    GirFFI creates bindings for GObject-based libraries at runtime based on introspection
    data provided by the GObject Introspection Repository (GIR) system. Bindings are created
    at runtime and use FFI to interface with the C libraries. In cases where the GIR does not
    provide enough or correct information to create sane bindings, overrides may be created.
  DESC

  s.files = Dir["{lib,test,tasks,examples}/**/*",
                "*.md",
                "Gemfile",
                "Rakefile",
                "COPYING.LIB"] & `git ls-files -z`.split("\0")

  s.rdoc_options = ["--main", "README.md"]
  s.extra_rdoc_files = ["DESIGN.md", "Changelog.md", "README.md", "TODO.md"]

  s.add_runtime_dependency("ffi", ["~> 1.8"])
  s.add_runtime_dependency("ffi-bit_masks", ["~> 0.1.1"])

  s.add_development_dependency("aruba", ["~> 0.14.1"])
  s.add_development_dependency("minitest", ["~> 5.12"])
  s.add_development_dependency("rake", ["~> 13.0"])
  s.add_development_dependency("rspec-mocks", ["~> 3.5"])
  s.add_development_dependency("simplecov", ["~> 0.18.0"])

  s.require_paths = ["lib"]
end
