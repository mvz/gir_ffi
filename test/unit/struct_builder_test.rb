require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

describe GirFFI::Builder::Type::Struct do
  describe "#pretty_print" do
    it "returns a class block" do
      mock(info = Object.new).safe_name { "Bar" }
      stub(info).namespace { "Foo" }

      builder = GirFFI::Builder::Type::Struct.new(info)

      assert_equal "class Bar\nend", builder.pretty_print
    end
  end

  describe "for a struct with a layout with a fixed-length array" do
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
      builder = GirFFI::Builder::Type::Struct.new @struct
      spec = builder.send :itypeinfo_to_ffitype_for_struct, @type
      assert_equal [:foo, 2], spec
    end

    it "creates the correct layout specification" do
      builder = GirFFI::Builder::Type::Struct.new @struct
      spec = builder.send :layout_specification
      assert_equal [:bar, [:foo, 2], 0], spec
    end
  end

  describe "for a struct without defined fields" do
    it "uses a single field of the parent struct type as the default layout" do
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
  end
end


