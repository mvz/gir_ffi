# frozen_string_literal: true
source 'https://rubygems.org'

# The gem's dependencies are specified in gir_ffi.gemspec
gemspec

if ENV['CI']
  if ENV['TRAVIS_RUBY_VERSION'] == '2.2'
    gem 'coveralls', group: :development
  end
else
  gem 'simplecov', '~> 0.12.0', group: :local_development, platform: :mri
  gem 'pry', '~> 0.10.4', group: :local_development
end
