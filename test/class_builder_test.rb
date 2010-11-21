require File.expand_path('test_helper.rb', File.dirname(__FILE__))
require 'gir_ffi'

class ClassBuilderTest < Test::Unit::TestCase
  context "The ClassBuilder" do
    should "use parent struct as default layout" do
      @gir = GirFFI::IRepository.default
      @gir.require 'GObject', nil

      @classbuilder = GirFFI::ClassBuilder.new 'Foo', 'Bar'

      stub(info = Object.new).parent { @gir.find_by_name 'GObject', 'Object' }
      stub(info).fields { [] }

      @classbuilder.instance_eval { @info = info }
      @classbuilder.instance_eval { @parent = info.parent }
      @classbuilder.instance_eval { @superclass = GObject::Object }

      spec = @classbuilder.send :layout_specification
      assert_equal [:parent, GObject::Object::Struct, 0], spec
    end

    context "for Gtk::Widget" do
      setup do
	@cbuilder = GirFFI::ClassBuilder.new 'Gtk', 'Widget'
      end

      context "looking at Gtk::Widget#show" do
	setup do
	  @go = get_method_introspection_data 'Gtk', 'Widget', 'show'
	end

	should "delegate definition to FunctionDefinitionBuilder" do
	  code = @cbuilder.send :function_definition, @go, Lib
	  expected = GirFFI::FunctionDefinitionBuilder.new(@go, Lib).generate
	  assert_equal cws(expected), cws(code)
	end

      end
    end

  end
end

