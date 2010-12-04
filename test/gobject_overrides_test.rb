require File.expand_path('test_helper.rb', File.dirname(__FILE__))
require 'gir_ffi'

class GObjectOverridesTest < Test::Unit::TestCase
  context "The GObject module with overridden functions" do
    setup do
      GirFFI.setup :GObject
      GirFFI.setup :Everything
    end

    context "the signal_connect function" do
      should "pass" do
	assert true
      end
    end

    context "the signal_emit function" do
      should "emit a signal" do
	a = 1
	o = Everything::TestSubObj.new
	GObject.signal_connect_data o, "test", Proc.new { a = 2 }, nil, nil, 0
	GObject.signal_emit o, "test"
	assert_equal 2, a
      end
    end
  end
end


