require 'rake/clean'
require 'bundler/gem_tasks'

load 'tasks/rubocop.rake'
load 'tasks/test.rake'

task default: 'test:all'
task default: 'test:features'
task default: :rubocop unless RUBY_ENGINE == 'rbx'
