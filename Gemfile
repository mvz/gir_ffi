source "http://rubygems.org"

# The gem's dependencies are specified in gir_ffi.gemspec
gemspec

if ENV["CI"]
  if RUBY_ENGINE == "ruby"
    gem 'coveralls', require: false
  end
else
  gem 'pry'
  gem 'ZenTest'
  gem 'autotest-suffix'

  if RUBY_ENGINE == 'ruby'
    gem 'simplecov', require: false
  end
end

gem 'rubysl', :platform => :rbx
