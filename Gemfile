# frozen_string_literal: true

source "https://rubygems.org"

# The gem's dependencies are specified in gir_ffi.gemspec
gemspec

gem "pry", "~> 0.12.0"

if ENV["CI"]
  gem "coveralls", group: :development if ENV["TRAVIS_RUBY_VERSION"] == "2.4"
end
