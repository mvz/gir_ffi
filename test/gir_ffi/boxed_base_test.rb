# frozen_string_literal: true

require "gir_ffi_test_helper"

GirFFI.setup :GIMarshallingTests

describe GirFFI::BoxedBase do
  describe "initialize" do
    it "sets up the held struct pointer" do
      # NOTE: GObject::Value uses the generic constructor, unlike
      # GIMarshallingTests::BoxedStruct, which has its own constructor.
      value = GObject::Value.new
      _(value.to_ptr).wont_be_nil
    end
  end

  describe "copy_from" do
    it "returns a copy with owned false" do
      original = GIMarshallingTests::BoxedStruct.new
      copy = GIMarshallingTests::BoxedStruct.copy_from(original)
      ptr = copy.to_ptr
      _(ptr).wont_be :==, original.to_ptr
      _(ptr).wont_be :autorelease? if ptr.respond_to? :autorelease?
      _(copy.struct).wont_be :owned?
    end
  end

  describe "wrap_own" do
    it "wraps and owns the supplied pointer" do
      original = GIMarshallingTests::BoxedStruct.new
      copy = GIMarshallingTests::BoxedStruct.wrap_own(original.to_ptr)
      ptr = copy.to_ptr
      _(ptr).must_equal original.to_ptr
      _(ptr).wont_be :autorelease? if ptr.respond_to? :autorelease?
      _(copy.struct).must_be :owned?
    end
  end

  describe "upon garbage collection" do
    it "frees and disowns the underlying struct if it is owned" do
      skip "cannot be reliably tested on JRuby" if jruby?

      allow(GObject).to receive(:boxed_free)
      gtype = GIMarshallingTests::BoxedStruct.gtype

      owned_struct = GIMarshallingTests::BoxedStruct.new.struct
      owned_ptr = owned_struct.to_ptr

      unowned_struct = GIMarshallingTests::BoxedStruct.new.struct
      unowned_struct.owned = false
      unowned_ptr = unowned_struct.to_ptr

      GC.start
      # Creating a new object is sometimes needed to trigger enough garbage collection.
      GIMarshallingTests::BoxedStruct.new
      sleep 1
      GC.start
      GC.start

      expect(GObject).to have_received(:boxed_free).with(gtype, owned_ptr)
      expect(GObject).not_to have_received(:boxed_free).with(gtype, unowned_ptr)
      _(owned_struct).wont_be :owned?
    end
  end
end
