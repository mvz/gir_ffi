require "rdoc/task"

RDoc::Task.new do |rdoc|
  rdoc.main = "README.rdoc"
  rdoc.rdoc_files.include "README.rdoc", "DESIGN.rdoc", "TODO.rdoc", "lib/**/*.rb"
end
