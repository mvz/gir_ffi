require 'rake/testtask'

namespace :test do

  Rake::TestTask.new(:run) do |t|
    t.libs = ['lib']
    t.test_files = FileList['test/**/*_test.rb']
    t.ruby_opts += ["-w"]
  end

  desc 'Build Regress test library and typelib'
  task :lib => "test/lib/Makefile" do
    sh %{cd test/lib && make}
  end

  task :run => :lib
end

file "test/lib/Makefile" => "test/lib/configure" do
  sh %{cd test/lib && ./configure}
end

file "test/lib/configure" do
  sh %{cd test/lib && NOCONFIGURE=1 ./autogen.sh}
end

desc 'Alias to test:run'
task :test => 'test:run'
