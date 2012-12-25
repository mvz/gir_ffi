require 'gir_ffi_test_helper'

describe GirFFI::Builder::Module do
  describe "#function_definition" do
    it "delegates to GirFFI::FunctionBuilder#generate" do
      builder = GirFFI::Builder::Module.new "Foo"

      mock(fb = Object.new).generate { "function body" }
      mock(GirFFI::FunctionBuilder).new("info", "lib") { fb }

      result = builder.send :function_definition, "info", "lib"

      assert_equal "function body", result
    end
  end

  describe "#sub_builder" do
    describe "for a :function argument" do
      it "creates a GirFFI::FunctionBuilder object" do
        builder = GirFFI::Builder::Module.new "Foo"
        mock(builder).libmodule { DummyLib }

        stub(info = Object.new).info_type { :function }

        result = builder.send :sub_builder, info
        assert_instance_of GirFFI::FunctionBuilder, result
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

