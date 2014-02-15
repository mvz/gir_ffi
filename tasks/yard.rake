begin
  require 'yard'

  YARD::Rake::YardocTask.new
rescue LoadError
end
