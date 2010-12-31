require File.expand_path('test_helper.rb', File.dirname(__FILE__))
require 'gir_ffi'

# Tests generated methods and functions in the Gio namespace.
class GeneratedGioTest < Test::Unit::TestCase
  context "In the generated Gio module" do
    setup do
      GirFFI.setup :Gio
    end

    should "create a GFile with #file_new_from_path" do
      assert_nothing_raised {
	Gio.file_new_for_path('/')
      }
    end
  end
end

