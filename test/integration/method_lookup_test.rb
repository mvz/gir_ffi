# frozen_string_literal: true

require "gir_ffi_test_helper"

# Tests how methods are looked up and generated on first use.
describe "Looking up methods" do
  before do
    save_module :Regress
    GirFFI.setup :Regress
  end

  describe "an instance method" do
    it "is found from a subclass" do
      assert_defines_instance_method Regress::TestObj, :forced_method
      refute_defines_instance_method Regress::TestSubObj, :forced_method

      sub_object = Regress::TestSubObj.new
      sub_object.forced_method
    end
  end

  describe "a class method" do
    it "is found from a subclass" do
      assert_defines_singleton_method Regress::TestObj, :static_method
      refute_defines_singleton_method Regress::TestSubObj, :static_method

      Regress::TestSubObj.static_method 42
    end
  end

  after do
    restore_module :Regress
  end
end
