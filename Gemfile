source "https://rubygems.org"

# The gem's dependencies are specified in gir_ffi.gemspec
gemspec

if ENV["CI"] && RUBY_ENGINE == "ruby"
  gem 'coveralls', require: false
end

gem 'rubysl', :platform => :rbx
