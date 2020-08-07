# frozen_string_literal: true

require "rake/clean"
require "bundler/gem_tasks"

clean_globs = [".yardoc",
               "coverage",
               "doc/**/*.{html,css,js}",
               "Gemfile.lock",
               "test/lib/.deps",
               "test/lib/.libs",
               "test/lib/Makefile",
               "test/lib/Makefile.in",
               "test/lib/*.{gir,typelib}",
               "test/lib/autom4te.cache",
               "test/lib/config.*",
               "test/lib/compile",
               "test/lib/configure",
               "test/lib/aclocal.m4",
               "test/lib/depcomp",
               "test/lib/install-sh",
               "test/lib/*.{so,la,lo,o}",
               "test/lib/libtool",
               "test/lib/ltmain.sh",
               "test/lib/m4/lt*.m4",
               "test/lib/m4/libtool.m4",
               "test/lib/missing",
               "test/lib/stamp-h1",
               "tmp"]

CLEAN.include(Rake::FileList.new(*clean_globs))

namespace :manifest do
  def gemmable_files
    Rake::FileList["{docs,examples,lib}/**/*", "COPYING.LIB"]
  end

  def manifest_files
    File.read("Manifest.txt").split
  end

  desc "Create or update manifest"
  task :generate do
    File.open("Manifest.txt", "w") do |manifest|
      gemmable_files.each { |file| manifest.puts file }
    end
  end

  desc "Check manifest"
  task :check do
    unless gemmable_files == manifest_files
      raise "Manifest check failed, try recreating the manifest"
    end
  end
end

load "tasks/test.rake"

task default: "test:all"
task default: "test:features"
task build: "manifest:check"
