require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

describe GirFFI::Builder::Module do
  describe "#pretty_print" do
    describe "for a module with no members" do
      it "returns just a module block" do
        gir = GObjectIntrospection::IRepository.default
        stub(gir).require("Foo", nil) { }
        mock(gir).infos("Foo") { [] }

        builder = GirFFI::Builder::Module.new "Foo"
        res = builder.pretty_print
        expected = "module Foo\nend"

        assert_equal expected, res
      end
    end

    describe "for a module with a function member" do
      it "returns a module block with pretty printed function inside" do
        stub(info = Object.new).info_type { :function }
        mock(subbuilder = Object.new).pretty_print { "def foo\n  function_body\nend" }

        gir = GObjectIntrospection::IRepository.default
        stub(gir).require("Foo", nil) { }
        mock(gir).infos("Foo") { [info] }

        builder = GirFFI::Builder::Module.new "Foo"
        stub(builder).libmodule { :bla }
        mock(GirFFI::Builder::Function).new(info, :bla) { subbuilder }

        res = builder.pretty_print
        expected = "module Foo\n  def foo\n    function_body\n  end\nend"

        assert_equal expected, res
      end
    end
  end

  describe "#function_definition" do
    it "delegates to GirFFI::Builder::Function#generate" do
      builder = GirFFI::Builder::Module.new "Foo"

      mock(fb = Object.new).generate { "function body" }
      mock(GirFFI::Builder::Function).new("info", "lib") { fb }

      result = builder.send :function_definition, "info", "lib"

      assert_equal "function body", result
    end
  end

  describe "#sub_builder" do
    describe "for a :function argument" do
      it "creates a GirFFI::Builder::Function object" do
        builder = GirFFI::Builder::Module.new "Foo"
        mock(builder).libmodule { DummyLib }

        stub(info = Object.new).info_type { :function }

        result = builder.send :sub_builder, info
        assert_instance_of GirFFI::Builder::Function, result
      end
    end

    describe "for an :object argument" do
      it "creates a GirFFI::Builder::Type::Object object" do
        builder = GirFFI::Builder::Module.new "Foo"

        stub(info = Object.new).info_type { :object }
        stub(info).namespace { "Foo" }
        stub(info).safe_name { "FooClass" }

        result = builder.send :sub_builder, info
        assert_instance_of GirFFI::Builder::Type::Object, result
      end
    end
  end

  describe "#build_namespaced_class" do
    it "raises a clear error if the named class does not exist" do
      gir = GObjectIntrospection::IRepository.default
      stub(gir).require("Foo", nil) { }

      builder = GirFFI::Builder::Module.new "Foo"

      mock(gir).find_by_name("Foo", "Bar") { nil }

      assert_raises NameError do
        builder.build_namespaced_class :Bar
      end
    end
  end
end

