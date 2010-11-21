require File.expand_path('test_helper.rb', File.dirname(__FILE__))
require 'gir_ffi'

class GObjectOverridesTest < Test::Unit::TestCase
  context "The GObject.signal_connect function" do
    setup do
      cleanup_module :GObject
      GirFFI.setup :GObject
    end

    should "pass" do
      assert true
    end
  end
end


