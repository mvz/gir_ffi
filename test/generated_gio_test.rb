require File.expand_path('test_helper.rb', File.dirname(__FILE__))

# Tests generated methods and functions in the Gio namespace.
class GeneratedGioTest < MiniTest::Spec
  context "In the generated Gio module" do
    setup do
      GirFFI.setup :Gio
    end

    should "create a GFile with #file_new_from_path" do
      assert_nothing_raised {
	Gio.file_new_for_path('/')
      }
    end

    if false
    context "the FileInfo class" do
      context "an instance" do
	setup do
	  file = Gio.file_new_for_path('/')
	  @fileinfo = file.query_info "*", :none, nil
	end

	should "hava a working #get_attribute_type method" do
	  assert_nothing_raised {
	    @fileinfo.get_attribute_type "standard::displayname"
	  }
	end
      end
    end
    end
  end
end

