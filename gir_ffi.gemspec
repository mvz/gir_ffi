# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name = "gir_ffi"
  s.version = "0.0.4"
  s.date = Date.today.to_s

  s.summary = "Ruby-FFI-based binding of the GObject Introspection Repository"
  s.description = "Ruby-FFI-based binding of the GObject Introspection Repository"

  s.authors = ["Matijs van Zuijlen"]
  s.email = ["matijs@matijs.net"]
  s.homepage = "http://www.github.com/mvz/ruby-gir-ffi"

  s.rdoc_options = ["--main", "README.rdoc"]

  s.files = Dir['{lib,test,tasks,examples}/**/*', "*.rdoc", "History.txt", "Rakefile"] & `git ls-files -z`.split("\0")
  s.extra_rdoc_files = ["DESIGN.rdoc", "History.txt", "README.rdoc", "TODO.rdoc"]
  s.test_files = `git ls-files -z -- test`.split("\0")

  s.add_runtime_dependency(%q<ffi>, ["~> 0.6.3"])
  s.add_development_dependency('shoulda', ["~> 2.11.3"])
  s.add_development_dependency('rr', ["~> 1.0.2"])

  s.require_paths = ["lib"]
end
