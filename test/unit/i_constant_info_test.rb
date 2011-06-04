require File.expand_path('../test_helper.rb', File.dirname(__FILE__))

describe GirFFI::IConstantInfo do
  describe "for GLib::ALLOCATOR_LIST, a constant of type :gint32" do
    before do
      @info = get_introspection_data 'GLib', 'ALLOCATOR_LIST'
    end

    it "returns :gint32 as its type" do
      assert_equal :gint32, @info.constant_type.tag
    end

    it "returns a value union with member :v_int32 with value 1" do
      assert_equal 1, @info.value[:v_int32]
    end
  end
end
