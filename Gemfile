# frozen_string_literal: true

source 'https://rubygems.org'

# The gem's dependencies are specified in gir_ffi.gemspec
gemspec

if ENV['CI']
  gem 'coveralls', group: :development if ENV['TRAVIS_RUBY_VERSION'] == '2.2'
else
  gem 'simplecov', '~> 0.15.0', group: :local_development, platform: :mri
end
