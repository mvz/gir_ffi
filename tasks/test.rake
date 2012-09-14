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

  define_test_task(:introspection) do |t|
    t.test_files = FileList['test/ffi-gobject_introspection/**/*_test.rb']
  end

  define_test_task(:main) do |t|
    t.test_files = FileList['test/gir_ffi_test.rb',
                            'test/gir_ffi/**/*_test.rb']
  end

  define_test_task(:overrides) do |t|
    t.test_files = FileList['test/ffi-gobject_test.rb',
                            'test/ffi-glib/**/*_test.rb',
                            'test/ffi-gobject/**/*_test.rb']
  end

  define_test_task(:integration) do |t|
    t.test_files = FileList['test/integration/**/*_test.rb']
  end

  desc 'Build Regress test library and typelib'
  task :lib => "test/lib/Makefile" do
    sh %{cd test/lib && make}
  end

  task :main => :lib
  task :overrides => :lib
  task :integration => :lib

  desc 'Run the entire test suite as one'
  define_test_task(:all) do |t|
    t.test_files = FileList['test/**/*_test.rb']
  end

  task :all => :lib

  desc 'Run all individual test suites separately'
  task :suites => [:base,
                   :introspection,
                   :main,
                   :overrides,
                   :integration]
end

file "test/lib/Makefile" => "test/lib/configure" do
  sh %{cd test/lib && ./configure --enable-maintainer-mode}
end

file "test/lib/configure" do
  sh %{cd test/lib && NOCONFIGURE=1 ./autogen.sh}
end
