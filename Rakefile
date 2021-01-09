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

load "tasks/test.rake"
load "tasks/manifest.rake"

task default: "test:all"
task default: "test:features"
task default: "manifest:check"
task build: "manifest:check"
