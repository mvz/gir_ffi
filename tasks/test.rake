require 'rake/testtask'

namespace :test do

  Rake::TestTask.new(:integration) do |t|
    t.libs = ['lib']
    t.test_files = FileList['test/integration/*_test.rb']
    t.ruby_opts += ["-w"]
  end

  Rake::TestTask.new(:run) do |t|
    t.libs = ['lib']
    t.test_files = FileList['test/*_test.rb']
    t.ruby_opts += ["-w"]
  end

  Rake::TestTask.new(:unit) do |t|
    t.libs = ['lib']
    t.test_files = FileList['test/unit/*_test.rb']
    t.ruby_opts += ["-w"]
  end

  Rake::TestTask.new(:gobjectintrospection) do |t|
    t.libs = ['lib']
    t.test_files = FileList['test/ffi-gobject_introspection/*_test.rb']
    t.ruby_opts += ["-w"]
  end

  Rake::TestTask.new(:glib) do |t|
    t.libs = ['lib']
    t.test_files = FileList['test/ffi-glib/*_test.rb']
    t.ruby_opts += ["-w"]
  end

  Rake::TestTask.new(:gobject) do |t|
    t.libs = ['lib']
    t.test_files = FileList['test/ffi-gobject/*_test.rb']
    t.ruby_opts += ["-w"]
  end

  Rake::TestTask.new(:gtk) do |t|
    t.libs = ['lib']
    t.test_files = FileList['test/ffi-gtk/*_test.rb']
    t.ruby_opts += ["-w"]
  end

  desc 'Build Regress test library and typelib'
  task :lib => "test/lib/Makefile" do
    sh %{cd test/lib && make}
  end

  task :run => :lib
  task :unit => :lib
  task :glib => :lib
  task :gobject => :lib
  task :integration => :lib

  desc 'Run rcov for the entire test suite'
  task :coverage => :lib do
    rm_f "coverage"
    system "rcov", "-Ilib", "--exclude", "\.gem\/,\/gems\/", *FileList['test/**/*_test.rb']
  end
end

file "test/lib/Makefile" => "test/lib/configure" do
  sh %{cd test/lib && ./configure --enable-maintainer-mode}
end

file "test/lib/configure" do
  sh %{cd test/lib && NOCONFIGURE=1 ./autogen.sh}
end

desc 'Run unit an integration tests'
task :test => ['test:gobjectintrospection',
  'test:unit', 'test:run', 'test:glib', 'test:gobject', 'test:gtk',
  'test:integration']
