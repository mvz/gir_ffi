require 'rake/clean'
require 'bundler/gem_helper'

class MyGemHelper < Bundler::GemHelper
  def version_tag
    "version-#{version}"
  end
end

MyGemHelper.install_tasks

load 'tasks/test.rake'
load 'tasks/valgrind.rake'

task :default => 'test:all'
