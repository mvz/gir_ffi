require 'rake/clean'
require 'bundler/gem_helper'

class MyGemHelper < Bundler::GemHelper
  def version_tag
    "version-#{version}"
  end
end

MyGemHelper.install_tasks

begin
  require 'repl_rake'
  ReplRake.setup
rescue LoadError
end

load 'tasks/test.rake'
load 'tasks/valgrind.rake'
load 'tasks/yard.rake'

task :default => 'test:all'
