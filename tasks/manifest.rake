# frozen_string_literal: true

require "rake/manifest/task"

Rake::Manifest::Task.new do |t|
  t.patterns = ["{docs,examples,lib}/**/*", "COPYING.LIB"]
end
