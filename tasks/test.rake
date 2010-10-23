
if test(?e, PROJ.test.file) or not PROJ.test.files.to_a.empty?
require 'rake/testtask'

namespace :test do

  Rake::TestTask.new(:run) do |t|
    t.libs = PROJ.libs
    t.test_files = if test(?f, PROJ.test.file) then [PROJ.test.file]
                   else PROJ.test.files end
    t.ruby_opts += PROJ.ruby_opts
    t.ruby_opts += PROJ.test.opts
  end

end  # namespace :test

desc 'Alias to test:run'
task :test => 'test:run'

end

# EOF
