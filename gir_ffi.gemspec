# frozen_string_literal: true

require_relative "lib/gir_ffi/version"

Gem::Specification.new do |spec|
  spec.name = "gir_ffi"
  spec.version = GirFFI::VERSION
  spec.authors = ["Matijs van Zuijlen"]
  spec.email = ["matijs@matijs.net"]

  spec.summary = "FFI-based GObject binding using the GObject Introspection Repository"
  spec.description = <<~DESC
    GirFFI creates bindings for GObject-based libraries at runtime based on introspection
    data provided by the GObject Introspection Repository (GIR) system. Bindings are created
    at runtime and use FFI to interface with the C libraries. In cases where the GIR does not
    provide enough or correct information to create sane bindings, overrides may be created.
  DESC
  spec.homepage = "http://www.github.com/mvz/ruby-gir-ffi"
  spec.license = "LGPL-2.1+"

  spec.required_ruby_version = ">= 2.5.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/mvz/gir_ffi"
  spec.metadata["changelog_uri"] = "https://github.com/mvz/gir_ffi/blob/master/Changelog.md"

  spec.files = File.read("Manifest.txt").split
  spec.rdoc_options = ["--main", "README.md"]
  spec.extra_rdoc_files = ["DESIGN.md", "Changelog.md", "README.md", "TODO.md"]
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "ffi", "~> 1.8"
  spec.add_runtime_dependency "ffi-bit_masks", "~> 0.1.1"

  spec.add_development_dependency "aruba", "~> 1.0.0"
  spec.add_development_dependency "minitest", "~> 5.12"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rake-manifest", "~> 0.1.0"
  spec.add_development_dependency "rexml", "~> 3.0"
  spec.add_development_dependency "rspec-mocks", "~> 3.5"
  spec.add_development_dependency "rubocop", "~> 0.93.0"
  spec.add_development_dependency "rubocop-minitest", "~> 0.10.1"
  spec.add_development_dependency "rubocop-packaging", "~> 0.5.0"
  spec.add_development_dependency "rubocop-performance", "~> 1.8.0"
  spec.add_development_dependency "simplecov", "~> 0.19.0"
end
