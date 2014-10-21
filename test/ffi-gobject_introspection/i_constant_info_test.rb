require 'introspection_test_helper'

describe GObjectIntrospection::IConstantInfo do
  describe "for GLib::USEC_PER_SEC, a constant of type :gint32" do
    before do
      @info = get_introspection_data 'GLib', 'USEC_PER_SEC'
    end

    it "returns :gint32 as its type" do
      assert_equal :gint32, @info.constant_type.tag
    end

    it "returns 1_000_000 as its value" do
      assert_equal 1_000_000, @info.value
    end
  end

  describe "for GLib::SOURCE_CONTINUE, a constant of type :gboolean" do
    before do
      @info = get_introspection_data 'GLib', 'SOURCE_CONTINUE'
    end

    it "returns :gboolean as its type" do
      assert_equal :gboolean, @info.constant_type.tag
    end

    it "returns true as its value" do
      assert_equal true, @info.value
    end
  end
end
