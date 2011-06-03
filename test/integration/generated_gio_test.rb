require File.expand_path('../test_helper.rb', File.dirname(__FILE__))

# Tests generated methods and functions in the Gio namespace.
class GeneratedGioTest < MiniTest::Spec
  context "In the generated Gio module" do
    setup do
      GirFFI.setup :Gio
    end

    describe "#file_new_for_path, a method returning an interface," do
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

    describe "the result of #file_new_from_path" do
      before do
        @it = Gio.file_new_for_path('/')
      end

      it "is able to set up a method in a class that is not the first ancestor" do
        anc = @it.class.ancestors
        assert_equal Gio::File, anc[1]
        assert_equal GObject::Object, anc[2]
        refute_includes Gio::File.instance_methods.map(&:to_s),
          'get_qdata'
        assert_includes GObject::Object.instance_methods.map(&:to_s),
          'get_qdata'
        @it.setup_and_call :get_qdata, 1
      end
    end

    context "the FileInfo class" do
      context "an instance" do
	setup do
	  file = Gio.file_new_for_path('/')
	  @fileinfo = file.query_info "*", :none, nil
	end

	should "hava a working #get_attribute_type method" do
	  type = @fileinfo.get_attribute_type "standard::display-name"
          assert_equal :string, type
	end
      end
    end
  end
end

