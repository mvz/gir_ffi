# frozen_string_literal: true

require "gir_ffi_test_helper"

describe GirFFI::Builders::InitializerBuilder do
  describe "#method_definition" do
    let(:builder) { GirFFI::Builders::InitializerBuilder.new function_info }
    let(:code) { builder.method_definition }

    describe "for constructors with the default name" do
      let(:function_info) { get_method_introspection_data "Regress", "TestObj", "new" }
      it "builds an initializer" do
        _(code).must_equal <<~CODE
          def initialize(obj)
            _v1 = Regress::TestObj.from(obj)
            _v2 = Regress::Lib.regress_test_obj_new _v1
            store_pointer(_v2)
          end
        CODE
      end
    end

    describe "for constructors with a custom name" do
      let(:function_info) do
        get_method_introspection_data "Regress", "TestObj", "new_from_file"
      end
      it "builds a custom initializer" do
        _(code).must_equal <<~CODE
          def initialize_from_file(x)
            _v1 = GirFFI::InPointer.from_utf8(x)
            _v2 = FFI::MemoryPointer.new(:pointer).write_pointer nil
            _v3 = Regress::Lib.regress_test_obj_new_from_file _v1, _v2
            GirFFI::ArgHelper.check_error(_v2)
            store_pointer(_v3)
          end
        CODE
      end
    end

    describe "for constructors for boxed types" do
      let(:function_info) do
        get_method_introspection_data "GIMarshallingTests", "BoxedStruct", "new"
      end

      it "builds an initializer that sets owned to true" do
        _(code).must_equal <<~CODE
          def initialize
            _v1 = GIMarshallingTests::Lib.gi_marshalling_tests_boxed_struct_new
            store_pointer(_v1)
            @struct.owned = true
          end
        CODE
      end
    end
  end
end
