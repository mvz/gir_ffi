require 'test_helper'

describe GObjectIntrospection::IConstantInfo do
  describe "for GLib::USEC_PER_SEC, a constant of type :gint32" do
    before do
      @info = get_introspection_data 'GLib', 'USEC_PER_SEC'
    end

    it "returns :gint32 as its type" do
      assert_equal :gint32, @info.constant_type.tag
    end

    it "returns a value union with member :v_int32 with value 1_000_000" do
      assert_equal 1_000_000, @info.value_union[:v_int32]
    end

    it "returns 1 as its value" do
      assert_equal 1_000_000, @info.value
    end
  end
end
