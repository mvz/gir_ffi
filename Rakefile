require 'rake/clean'
require 'bundler/gem_tasks'

begin
  require 'repl_rake'
  ReplRake.setup
rescue LoadError
end

load 'tasks/test.rake'
load 'tasks/valgrind.rake'
load 'tasks/yard.rake'

task :default => 'test:all'
