require 'shoulda'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

class Test::Unit::TestCase
  def cws code
    code.gsub(/(^\s*|\s*$)/, "")
  end
end
