require 'rake/clean'
require 'bundler/gem_tasks'

load 'tasks/rubocop.rake'
load 'tasks/test.rake'

task :default => ['test:all', 'rubocop']
