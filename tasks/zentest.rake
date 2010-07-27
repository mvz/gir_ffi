if HAVE_ZENTEST

# --------------------------------------------------------------------------
if test(?e, PROJ.test.file) or not PROJ.test.files.to_a.empty?
require 'autotest'

namespace :test do
  task :autotest do
    Autotest.run
  end
end

desc "Run the autotest loop"
task :autotest => 'test:autotest'

end  # if test

end  # if HAVE_ZENTEST

# EOF
