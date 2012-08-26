require 'rake/testtask'

namespace :test do
  def define_test_task name
    Rake::TestTask.new(name) do |t|
      t.libs = ['lib']
      t.ruby_opts += ["-w -Itest"]
      yield t
    end
  end

  define_test_task(:base) do |t|
    t.test_files = FileList['test/gir_ffi-base/**/*_test.rb']
  end

  define_test_task(:gobjectintrospection) do |t|
    t.test_files = FileList['test/ffi-gobject_introspection/*_test.rb']
  end

  define_test_task(:gir_ffi) do |t|
    t.test_files = FileList['test/gir_ffi/**/*_test.rb']
  end

  define_test_task(:glib) do |t|
    t.test_files = FileList['test/ffi-glib/*_test.rb']
  end

  define_test_task(:gobject) do |t|
    t.test_files = FileList['test/ffi-gobject/*_test.rb']
  end

  define_test_task(:run) do |t|
    t.test_files = FileList['test/*_test.rb']
  end

  define_test_task(:unit) do |t|
    t.test_files = FileList['test/unit/*_test.rb']
  end

  define_test_task(:integration) do |t|
    t.test_files = FileList['test/integration/*_test.rb']
  end

  desc 'Build Regress test library and typelib'
  task :lib => "test/lib/Makefile" do
    sh %{cd test/lib && make}
  end

  task :gir_ffi => :lib
  task :glib => :lib
  task :gobject => :lib

  task :run => :lib
  task :unit => :lib

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
task :test => [
  'test:base',
  'test:gobjectintrospection',
  'test:glib',
  'test:gobject',
  'test:unit',
  'test:run',
  'test:integration',
]
