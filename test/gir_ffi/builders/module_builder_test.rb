require 'gir_ffi_test_helper'

describe GirFFI::Builders::ModuleBuilder do
  describe "#function_definition" do
    it "delegates to GirFFI::Builders::FunctionBuilder#generate" do
      builder = GirFFI::Builders::ModuleBuilder.new "Foo"

      mock(fb = Object.new).generate { "function body" }
      mock(GirFFI::Builders::FunctionBuilder).new("info") { fb }

      result = builder.send :function_definition, "info"

      assert_equal "function body", result
    end
  end

  describe "#sub_builder" do
    describe "for a :function argument" do
      it "creates a GirFFI::Builders::FunctionBuilder object" do
        builder = GirFFI::Builders::ModuleBuilder.new "Foo"

        stub(info = Object.new).info_type { :function }

        result = builder.send :sub_builder, info
        assert_instance_of GirFFI::Builders::FunctionBuilder, result
      end
    end

    describe "for an :object argument" do
      it "creates a GirFFI::Builders::ObjectBuilder object" do
        builder = GirFFI::Builders::ModuleBuilder.new "Foo"

        stub(info = Object.new).info_type { :object }
        stub(info).namespace { "Foo" }
        stub(info).safe_name { "FooClass" }

        result = builder.send :sub_builder, info
        assert_instance_of GirFFI::Builders::ObjectBuilder, result
      end
    end
  end

  describe "#build_namespaced_class" do
    it "raises a clear error if the named class does not exist" do
      gir = GObjectIntrospection::IRepository.default
      stub(gir).require("Foo", nil) { }

      builder = GirFFI::Builders::ModuleBuilder.new "Foo"

      mock(gir).find_by_name("Foo", "Bar") { nil }

      assert_raises NameError do
        builder.build_namespaced_class :Bar
      end
    end
  end
end

