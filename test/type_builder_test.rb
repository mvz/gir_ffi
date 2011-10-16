require File.expand_path('gir_ffi_test_helper.rb', File.dirname(__FILE__))

class TypeBuilderTest < MiniTest::Spec
  context "The Builder::Type class" do
    should "use parent struct as default layout" do
      @gir = GObjectIntrospection::IRepository.default
      @gir.require 'GObject', nil

      stub(info = Object.new).parent { @gir.find_by_name 'GObject', 'Object' }
      stub(info).fields { [] }
      stub(info).info_type { :object }
      stub(info).safe_name { 'Bar' }
      stub(info).namespace { 'Foo' }

      @classbuilder = GirFFI::Builder::Type::Object.new info

      spec = @classbuilder.send :layout_specification
      assert_equal [:parent, GObject::Object::Struct, 0], spec
    end

    describe "for a layout with a fixed-length array" do
      before do
        stub(subtype = Object.new).pointer? { false }
        stub(subtype).tag { :foo }

        stub(@type = Object.new).pointer? { false }
        stub(@type).tag { :array }
        stub(@type).array_fixed_size { 2 }
        stub(@type).param_type { subtype }

        stub(field = Object.new).field_type { @type }
        stub(field).name { "bar" }
        stub(field).offset { 0 }

        stub(@struct = Object.new).safe_name { 'Bar' }
        stub(@struct).namespace { 'Foo' }
        stub(@struct).fields { [ field ] }
      end

      it "creates the correct ffi type for the array" do
        builder = GirFFI::Builder::Type::RegisteredType.new @struct
        spec = builder.send :itypeinfo_to_ffitype_for_struct, @type
        assert_equal [:foo, 2], spec
      end

      it "creates the correct layout specification" do
        builder = GirFFI::Builder::Type::Struct.new @struct
        spec = builder.send :layout_specification
        assert_equal [:bar, [:foo, 2], 0], spec
      end
    end

    context "for Gtk::Widget" do
      setup do
	@cbuilder = GirFFI::Builder::Type::Object.new get_introspection_data('Gtk', 'Widget')
      end

      context "looking at Gtk::Widget#show" do
	setup do
	  @go = get_method_introspection_data 'Gtk', 'Widget', 'show'
	end

	should "delegate definition to Builder::Function" do
	  code = @cbuilder.send :function_definition, @go
	  expected = GirFFI::Builder::Function.new(@go, Gtk::Lib).generate
	  assert_equal cws(expected), cws(code)
	end

      end
    end

    context 'the find_signal method' do
      should 'find the signal "test" for TestObj' do
	builder = GirFFI::Builder::Type::Object.new get_introspection_data('Regress', 'TestObj')
	sig = builder.find_signal 'test'
	assert_equal 'test', sig.name
      end

      should 'find the signal "test" for TestSubObj' do
	builder = GirFFI::Builder::Type::Object.new get_introspection_data('Regress', 'TestSubObj')
	sig = builder.find_signal 'test'
	assert_equal 'test', sig.name
      end

      should 'find the signal "changed" for Gtk::Entry' do
	builder = GirFFI::Builder::Type::Object.new get_introspection_data('Gtk', 'Entry')
	sig = builder.find_signal 'changed'
	assert_equal 'changed', sig.name
      end
    end

    context "for GObject::TypeCValue (a union)" do
      setup do
	@cbuilder = GirFFI::Builder::Type::Union.new get_introspection_data('GObject', 'TypeCValue')
      end

      should "returns false looking for a method that doesn't exist" do
	assert_equal false, @cbuilder.setup_instance_method('blub')
      end
    end
  end
end

