require 'gir_ffi_test_helper'

describe GirFFI::Builder::Type::Enum do
  describe "creating Regress::TestEnum" do
    before do
      save_module :Regress
    end

    it "makes the created type know its proper name" do
      info = get_introspection_data 'Regress', 'TestEnum'
      builder = GirFFI::Builder::Type::Enum.new info
      enum = builder.build_class
      enum.inspect.must_equal "Regress::TestEnum"
    end

    after do
      restore_module :Regress
    end
  end
end

