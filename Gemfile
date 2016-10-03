# frozen_string_literal: true
source 'https://rubygems.org'

# The gem's dependencies are specified in gir_ffi.gemspec
gemspec

gem 'rubocop', '~> 0.43.0', group: :development

gem 'mutant', git: 'https://github.com/mbj/mutant.git',
              branch: 'feature/minitest-integration',
              platform: :mri_23,
              group: :development

if ENV['CI']
  if ENV['TRAVIS_RUBY_VERSION'] == '2.2'
    gem 'coveralls', group: :development
  end
else
  gem 'simplecov', '~> 0.12.0', group: :development, platform: :mri
  gem 'pry', '~> 0.10.0', group: :development
end
