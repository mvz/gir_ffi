require File.expand_path('test_helper.rb', File.dirname(__FILE__))

# Tests generated methods and functions in the Gio namespace.
class GeneratedGioTest < MiniTest::Spec
  context "In the generated Gio module" do
    setup do
      GirFFI.setup :Gio
    end

    describe "#file_new_from_path, a method returning an interface," do
      it "does not throw an error when generated" do
        assert_nothing_raised {
          Gio.file_new_for_path('/')
        }
      end

      it "returns an object of a more specific class" do
        file = Gio.file_new_for_path('/')
        refute_instance_of Gio::File, file
        assert_includes file.class.ancestors, Gio::File
      end
    end

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

