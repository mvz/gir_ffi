require 'yard'

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb', "DESIGN.rdoc", "TODO.rdoc"]
  t.options = ['--private', '--protected', '--readme',  'README.rdoc']
end
