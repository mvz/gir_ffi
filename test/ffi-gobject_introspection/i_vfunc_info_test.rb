# frozen_string_literal: true

require "introspection_test_helper"

describe GObjectIntrospection::IVFuncInfo do
  let(:vfunc_info) do
    get_vfunc_introspection_data "GIMarshallingTests", "Object", "method_int8_in"
  end

  let(:throwing_vfunc_info) do
    get_vfunc_introspection_data "GIMarshallingTests", "Object", "vfunc_meth_with_err"
  end

  let(:vfunc_info_with_different_invoker) do
    get_vfunc_introspection_data "Regress", "TestObj", "matrix"
  end

  describe "#throws?" do
    it "returns false if there is no error argument" do
      _(vfunc_info).wont_be :throws?
    end

    it "returns true if there is and error argument" do
      _(throwing_vfunc_info).must_be :throws?
    end
  end

  describe "#invoker" do
    it "returns nil if no invoker method is present" do
      _(throwing_vfunc_info.invoker).must_be_nil
    end

    it "returns info for the invoker method if present" do
      _(vfunc_info.invoker.name).must_equal "method_int8_in"
    end

    it "returns the correct invoker even if named differently" do
      _(vfunc_info_with_different_invoker.invoker.name).must_equal "do_matrix"
    end
  end
end
