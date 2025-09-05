# frozen_string_literal: true

require "gir_ffi_test_helper"

describe GirFFI::AllocationHelper do
  describe ".free_after" do
    before do
      allow(GirFFI::LibC).to receive(:free)
    end

    it "frees the passed-in pointer" do
      ptr = double("pointer", null?: false)
      GirFFI::AllocationHelper.free_after(ptr) { nil }
      expect(GirFFI::LibC).to have_received(:free).with(ptr)
    end

    it "does not free a passed-in null pointer" do
      ptr = double("pointer", null?: true)
      GirFFI::AllocationHelper.free_after(ptr) { nil }
      expect(GirFFI::LibC).not_to have_received(:free)
    end

    it "yields ptr to the block" do
      ptr = double("pointer", null?: false)
      foo = nil
      GirFFI::AllocationHelper.free_after(ptr) { foo = _1 }

      _(foo).must_equal ptr
    end

    it "returns the result of the block" do
      ptr = double("pointer", null?: false)
      result = GirFFI::AllocationHelper.free_after(ptr) { "bar" }

      _(result).must_equal "bar"
    end
  end
end
