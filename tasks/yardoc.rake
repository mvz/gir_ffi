require 'yard'

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']
  t.options = ['--private', '--protected', '--readme',  'README.rdoc', "--files", "DESIGN.rdoc,TODO.rdoc"]
end
