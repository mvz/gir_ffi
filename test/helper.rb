require 'shoulda'
require File.expand_path('../lib/girffi.rb', File.dirname(__FILE__))

class Test::Unit::TestCase
  def cws code
    code.gsub(/(^\s*|\s*$)/, "")
  end
end
