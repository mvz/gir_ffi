require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

# Since the tests will call Gtk+ functions, Gtk+ must be initialized.
GirFFI.setup :Gtk, '2.0'
Gtk.init

# Tests generated methods and functions in the Gtk namespace.
class GeneratedGtkTest < MiniTest::Spec
  context "In the generated Gtk module" do
    context "a Gtk::Builder instance" do
      setup do
	@builder = Gtk::Builder.new
	@spec = '
	<interface>
	<object class="GtkButton" id="foo">
	<signal handler="on_button_clicked" name="clicked"/>
	</object>
	</interface>
	'
      end

      should "load spec" do
	assert_nothing_raised { @builder.add_from_string @spec, @spec.length }
      end

      context "its #get_object method" do
	should "return objects of the proper class" do
	  @builder.add_from_string @spec, @spec.length
	  o = @builder.get_object "foo"
	  assert_instance_of Gtk::Button, o
	end
      end

      context "its #connect_signals_full method" do
	setup do
	  @builder.add_from_string @spec, @spec.length
	end
	should "pass arguments correctly" do
	  aa = nil
	  @builder.connect_signals_full Proc.new {|*args| aa = args}, nil
	  b, o, sn, hn, co, f, ud = aa
	  assert_instance_of Gtk::Builder, b
	  assert_equal b.to_ptr, @builder.to_ptr
	  assert_instance_of Gtk::Button, o
	  assert_equal "clicked", sn
	  assert_equal "on_button_clicked", hn
	  assert_equal nil, co
	  assert_equal 0, f
	  assert_equal nil, ud
	end
      end
    end

    context "a Gtk::Window instance" do
      setup do
        @w = Gtk::Window.new :toplevel
      end

      should "start with a refcount of 2 (one for us, one for GTK+)" do
        assert_equal 2, ref_count(@w)
      end
    end

    context "Gtk::RadioButton" do
      context ".new" do
        should "work when called with nil" do
          assert_nothing_raised {
            Gtk::RadioButton.new nil
          }
        end
      end

      context "#get_group" do
        should "return a GLib::SList object" do
          btn = Gtk::RadioButton.new nil
          grp = btn.get_group
          assert_instance_of GLib::SList, grp
        end
      end

      context ".new" do
        should "work when called with the result of #get_group" do
          assert_nothing_raised {
            btn = Gtk::RadioButton.new nil
            grp = btn.get_group
            btn2 = Gtk::RadioButton.new grp
          }
        end
      end

    end
  end
end

