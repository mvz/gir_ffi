require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

describe GirFFI::Builder::Module do
  describe "#pretty_print" do
    it "returns just a module block for a module with no members" do
      gir = GObjectIntrospection::IRepository.default
      mock(gir).require("Foo", nil) { }
      mock(gir).infos("Foo") { [] }

      builder = GirFFI::Builder::Module.new "Foo"
      res = builder.pretty_print
      expected = "module Foo\nend\n"

      assert_equal expected, res
    end
  end

  describe "#function_definition" do
    it "delegates to GirFFI::Builder::Function#generate" do
      builder = GirFFI::Builder::Module.new "Foo"

      mock(fb = Object.new).generate { "function body" }
      mock(GirFFI::Builder::Function).new("info", "lib") { fb }

      result = builder.function_definition "info", "lib"

      assert_equal "function body", result
    end
  end
end

