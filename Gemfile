source 'https://rubygems.org'

# The gem's dependencies are specified in gir_ffi.gemspec
gemspec

if ENV['CI']
  gem 'coveralls', type: :development, platform: :mri
else
  gem 'simplecov', '~> 0.9.0', type: :development, platform: :mri
  gem 'pry', '~> 0.10.0', type: :development
end
