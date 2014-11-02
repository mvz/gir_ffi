require 'gir_ffi_test_helper'

describe GirFFI::Builders::CallbackReturnValueBuilder do
  let(:var_gen) { GirFFI::VariableNameGenerator.new }
  let(:return_value_info) { GirFFI::ReturnValueInfo.new(type_info) }
  let(:type_info) { callback_info.return_type }
  let(:builder) {
    GirFFI::Builders::CallbackReturnValueBuilder.new(var_gen,
                                                                   return_value_info)
  }

  before do
    skip unless callback_info
  end

  describe "for :gint32" do
    let(:callback_info) { get_introspection_data("GIMarshallingTests", "CallbackIntInt") }

    it "has no statements in #post_conversion" do
      builder.post_conversion.must_equal []
    end

    it "returns the result of the callback directly" do
      builder.capture_variable_name.must_equal "_v1"
      builder.return_value_name.must_equal "_v1"
    end
  end

  describe "for :void" do
    let(:callback_info) {
      get_introspection_data("GIMarshallingTests",
                                                 "CallbackMultipleOutParameters")
    }

    it "has no statements in #post_conversion" do
      builder.post_conversion.must_equal []
    end

    it "returns nothing" do
      builder.capture_variable_name.must_be_nil
      builder.return_value_name.must_be_nil
    end
  end

  describe "for :enum" do
    let(:callback_info) {
      get_vfunc_introspection_data("GIMarshallingTests",
                                                       "Object",
                                                       "vfunc_return_enum")
    }

    it "converts the result" do
      # Ensure variable names are generated in order
      builder.capture_variable_name.must_equal "_v1"
      builder.post_conversion.must_equal ["_v2 = GIMarshallingTests::Enum.from(_v1)"]
    end

    it "returns the result of the conversion" do
      builder.capture_variable_name.must_equal "_v1"
      builder.return_value_name.must_equal "_v2"
    end
  end

  describe "for :object" do
    let(:callback_info) {
      get_vfunc_introspection_data("GIMarshallingTests",
                                                       "Object",
                                                       "vfunc_return_object_transfer_full")
    }

    it "converts the result to a pointer" do
      # Ensure variable names are generated in order
      builder.capture_variable_name.must_equal "_v1"
      builder.post_conversion.must_equal ["_v2 = GObject::Object.from(_v1).to_ptr"]
    end

    it "returns the result of the conversion" do
      builder.capture_variable_name.must_equal "_v1"
      builder.return_value_name.must_equal "_v2"
    end
  end
end
