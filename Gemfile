source 'https://rubygems.org'

# The gem's dependencies are specified in gir_ffi.gemspec
gemspec

if ENV['CI']
  if ENV['TRAVIS_RUBY_VERSION'] == '2.2'
    gem 'coveralls', type: :development
  end
else
  gem 'simplecov', '~> 0.11.0', type: :development, platform: :mri
  gem 'pry', '~> 0.10.0', type: :development
end
