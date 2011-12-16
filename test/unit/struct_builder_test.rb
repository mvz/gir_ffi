require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

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
        # FIXME: Loads of mocks. Make info objects create their own builders.

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
      # FIXME: Push down stubs only into tests that need them.
      # FIXME: Test WithLayout directly.
      # FIXME: Move tests to create individual field layout to IFieldInfo
      #        tests.
      stub(@type = Object.new).pointer? { false }
      stub(@type).tag { :gint32 }

      stub(field = Object.new).field_type { @type }
      stub(field).name { "bar" }
      stub(field).offset { 0 }
      stub(field).writable? { true }
      stub(field).layout_specification { [:bar, :int32, 0] }

      stub(@struct = Object.new).safe_name { 'Bar' }
      stub(@struct).namespace { 'Foo' }
      stub(@struct).fields { [ field ] }
      stub(@struct).find_method { }

      @builder = GirFFI::Builder::Type::Struct.new @struct
    end

    it "creates the correct layout specification" do
      spec = @builder.send :layout_specification
      assert_equal [:bar, :int32, 0], spec
    end

    it "creates getter and setter methods" do
      m = Module.new { module Lib; end }
      stub(GirFFI::Builder).build_module('Foo') { m }

      c = Class.new

      refute c.method_defined?(:bar)
      refute c.method_defined?(:bar=)

      @builder.instance_eval { @klass = c }
      @builder.send :setup_field_accessors

      assert c.method_defined?(:bar)
      assert c.method_defined?(:bar=)
    end
  end

  describe "for a struct with a layout with a fixed-length array" do
    before do
      # FIXME: Push down stubs only into tests that need them.
      # FIXME: Test WithLayout directly.
      # FIXME: Move tests to create individual field layout to IFieldInfo
      #        tests.
      stub(subtype = Object.new).pointer? { false }
      stub(subtype).tag { :foo }

      stub(@type = Object.new).pointer? { false }
      stub(@type).tag { :array }
      stub(@type).array_fixed_size { 2 }
      stub(@type).param_type { subtype }

      stub(field = Object.new).field_type { @type }
      stub(field).name { "bar" }
      stub(field).offset { 0 }
      stub(field).layout_specification { [:bar, [:foo, 2], 0] }

      stub(@struct = Object.new).safe_name { 'Bar' }
      stub(@struct).namespace { 'Foo' }
      stub(@struct).fields { [ field ] }
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


