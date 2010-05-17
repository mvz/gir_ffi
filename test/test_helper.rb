require 'shoulda'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

# Need a dummy module for some tests.
module Lib
end

class Test::Unit::TestCase
  def cws code
    code.gsub(/(^\s*|\s*$)/, "")
  end
end
