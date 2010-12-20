require 'rake/clean'

# Load the other rake files in the tasks folder
tasks_dir = File.expand_path(File.dirname(__FILE__))
rakefiles = Dir.glob(File.join(tasks_dir, '*.rake')).sort
import(*rakefiles)
