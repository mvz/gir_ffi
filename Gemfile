source "http://rubygems.org"

# The gem's dependencies are specified in gir_ffi.gemspec
gemspec

if ENV["CI"]
  gem 'coveralls', require: false
else
  gem 'pry'
  gem 'ZenTest'
  gem 'autotest-suffix'

  if RUBY_VERSION >= "1.9"
    gem 'simplecov'
  end
end

gem 'rubysl', :platform => :rbx
