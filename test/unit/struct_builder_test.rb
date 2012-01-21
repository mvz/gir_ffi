require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

# FIXME: Test WithLayout directly, rather than through Struct.
describe GirFFI::Builder::Type::Struct do
  describe "#pretty_print" do
    describe "for a struct with no methods" do
      it "returns a class block" do
        mock(info = Object.new).safe_name { "Bar" }
        stub(info).namespace { "Foo" }
        stub(info).get_methods { [] }

        builder = GirFFI::Builder::Type::Struct.new(info)

        assert_equal "class Bar\nend", builder.pretty_print
      end
    end

    describe "for a struct with a method" do
      it "returns a class block with the pretty printed method inside" do
        # FIXME: Loads of mocks.

        # Function info and its builder
        stub(func_info = Object.new).info_type { :function }
        mock(func_builder = Object.new).pretty_print { "def foo\n  function_body\nend" }
        mock(GirFFI::Builder::Function).new(func_info, :bla) { func_builder }

        # Struct info
        mock(info = Object.new).safe_name { "Bar" }
        stub(info).namespace { "Foo" }
        mock(info).get_methods { [func_info] }

        # Struct builder
        builder = GirFFI::Builder::Type::Struct.new(info)
        stub(builder).lib { :bla }

        res = builder.pretty_print
        expected = "class Bar\n  def foo\n    function_body\n  end\nend"

        assert_equal expected, res
      end
    end
  end

  describe "for a struct with a simple layout" do
    before do
      @field = Object.new

      @struct = Object.new
      stub(@struct).safe_name { 'Bar' }
      stub(@struct).namespace { 'Foo' }
      stub(@struct).fields { [ @field ] }

      @builder = GirFFI::Builder::Type::Struct.new @struct
    end

    it "creates the correct layout specification" do
      mock(@field).layout_specification { [:bar, :int32, 0] }
      spec = @builder.send :layout_specification
      assert_equal [:bar, :int32, 0], spec
    end

    it "creates getter and setter methods" do
      # FIXME: Loads of stubs.

      stub(type = Object.new).pointer? { false }
      stub(type).tag { :gint32 }

      stub(@field).field_type { type }
      stub(@field).name { "bar" }
      stub(@field).writable? { true }

      stub(@struct).find_method { }

      m = Module.new { module Lib; end }
      stub(GirFFI::Builder).build_module('Foo') { m }

      c = Class.new
      c::Struct = Class.new

      refute c.method_defined?(:bar)
      refute c.method_defined?(:bar=)

      @builder.instance_eval {
        @klass = c
        @structklass = c::Struct
      }
      @builder.send :setup_field_accessors

      assert c.method_defined?(:bar)
      assert c.method_defined?(:bar=)
    end
  end

  describe "for a struct with a layout with a complex type" do
    it "does not flatten the complex type specification" do
      mock(simplefield = Object.new).layout_specification { [:bar, :foo, 0] }
      mock(complexfield = Object.new).layout_specification { [:baz, [:qux, 2], 0] }
      mock(struct = Object.new).fields { [ simplefield, complexfield ] }

      stub(struct).safe_name { 'Bar' }
      stub(struct).namespace { 'Foo' }

      builder = GirFFI::Builder::Type::Struct.new struct
      spec = builder.send :layout_specification
      assert_equal [:bar, :foo, 0, :baz, [:qux, 2], 0], spec
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
