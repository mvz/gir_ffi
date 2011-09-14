require File.expand_path('gir_ffi_test_helper.rb', File.dirname(__FILE__))

class ModuleBuilderTest < MiniTest::Spec
  context "The Builder::Module object" do
    context "for Gtk" do
      setup do
	@mbuilder = GirFFI::Builder::Module.new('Gtk')
      end

      context "looking at Gtk.main" do
	setup do
	  @go = get_introspection_data 'Gtk', 'main'
	end

	should "build correct definition of Gtk.main" do
	  code = @mbuilder.send :function_definition, @go, Lib
	  expected = "def main\n::Lib.gtk_main\nend"
	  assert_equal cws(expected), cws(code)
	end
      end

      context "looking at Gtk.init" do
	setup do
	  @go = get_introspection_data 'Gtk', 'init'
	end

	should "delegate definition to Builder::Function" do
	  code = @mbuilder.send :function_definition, @go, Lib
	  expected = GirFFI::Builder::Function.new(@go, Lib).generate
	  assert_equal cws(expected), cws(code)
	end
      end
    end

    context "for Regress" do
      setup do
	@mbuilder = GirFFI::Builder::Module.new('Regress')
      end

      context "looking at Regress.test_callback_destroy_notify" do
	setup do
	  @go = get_introspection_data 'Regress', 'test_callback_destroy_notify'
	end

	should "delegate definition to Builder::Function" do
	  code = @mbuilder.send :function_definition, @go, Lib
	  expected = GirFFI::Builder::Function.new(@go, Lib).generate
	  assert_equal cws(expected), cws(code)
	end
      end
    end
  end
end
