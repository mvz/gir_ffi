require File.expand_path('test_helper.rb', File.dirname(__FILE__))
require 'gir_ffi'

# Tests generated methods and functions in the Gtk namespace.
class GtkTest < Test::Unit::TestCase
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
    end
  end
end

