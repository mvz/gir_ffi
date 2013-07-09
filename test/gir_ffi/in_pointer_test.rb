require 'gir_ffi_test_helper'

require 'gir_ffi/in_pointer'

describe GirFFI::InPointer do
  describe ".from_array" do
    it "returns nil when passed nil" do
      result = GirFFI::InPointer.from_array :gint32, nil
      assert_nil result
    end

    it "handles type tag :GType" do
      GirFFI::InPointer.from_array :GType, [2]
    end

    it "handles enum types" do
      e = Module.new do
        extend GirFFI::EnumBase
        self::Enum = FFI::Enum.new [:foo, :bar, :baz]
      end
      ptr = GirFFI::InPointer.from_array e, [:bar, :foo, :baz]
      ptr.read_array_of_int32(3).must_equal [1, 0, 2]
    end

    it "handles struct types" do
      e = Class.new do
        self::Struct = Class.new(FFI::Struct) do
          layout :foo, :int32, :bar, :int32
        end
      end
      struct = e::Struct.allocate
      struct[:foo] = 42
      struct[:bar] = 24
      ptr = GirFFI::InPointer.from_array e, [struct]
      ptr.wont_equal struct.to_ptr
      new_struct = e::Struct.new ptr
      new_struct[:foo].must_equal 42
      new_struct[:bar].must_equal 24
    end

    it "handles typed pointers" do
      p1 = GirFFI::InPointer.from :gint32, 42
      p2 = GirFFI::InPointer.from :gint32, 24

      ptr = GirFFI::InPointer.from_array [:pointer, :uint32], [p1, p2]

      ptr.read_array_of_pointer(2).must_equal [p1, p2]
    end
  end

  describe "an instance created with .from_array :gint32" do
    before do
      @result = GirFFI::InPointer.from_array :gint32, [24, 13]
    end

    it "holds a pointer to the correct input values" do
      assert_equal 24, @result.get_int(0)
      assert_equal 13, @result.get_int(4)
    end

    it "is an instance of GirFFI::InPointer" do
      assert_instance_of GirFFI::InPointer, @result
    end

    it "is zero-terminated" do
      assert_equal 0, @result.get_int(8)
    end
  end

  describe "an instance created with .from_array :utf8" do
    before do
      @result = GirFFI::InPointer.from_array :utf8, ["foo", "bar", "baz"]
    end

    it "returns an array of pointers to strings" do
      ary = @result.read_array_of_pointer(3)
      assert_equal ["foo", "bar", "baz"], ary.map {|p| p.read_string}
    end
  end

  describe "an instance created with .from_array :filename" do
    before do
      @result = GirFFI::InPointer.from_array :filename, ["foo", "bar", "baz"]
    end

    it "returns an array of pointers to strings" do
      ary = @result.read_array_of_pointer(3)
      assert_equal ["foo", "bar", "baz"], ary.map {|p| p.read_string}
    end
  end

  describe "an instance created with .from :utf8" do
    before do
      @result = GirFFI::InPointer.from :utf8, "foo"
    end

    it "returns a pointer to the given string" do
      assert_equal "foo", @result.read_string
    end

    it "is an instance of GirFFI::InPointer" do
      assert_instance_of GirFFI::InPointer, @result
    end
  end

  describe "an instance created with .from :guint32" do
    before do
      @result = GirFFI::InPointer.from :guint32, 12345
    end

    it "returns a pointer with an address equal to the given value" do
      assert_equal 12345, @result.address
    end

    it "is an instance of GirFFI::InPointer" do
      assert_instance_of GirFFI::InPointer, @result
    end
  end

  describe "an instance created with .from :filename" do
    before do
      @result = GirFFI::InPointer.from :filename, "foo"
    end

    it "returns a pointer to the given string" do
      assert_equal "foo", @result.read_string
    end
  end

  describe ".from" do
    it "returns nil when passed nil" do
      result = GirFFI::InPointer.from :foo, nil
      assert_nil result
    end

    it "sets the pointer's address to the passed value for type :gint8" do
      result = GirFFI::InPointer.from :gint8, 23
      assert_equal 23, result.address
    end

    it "handles enum types" do
      e = Module.new do
        self::Enum = FFI::Enum.new [:foo, :bar, :baz]
        def self.[](val)
          self::Enum[val]
        end
      end
      ptr = GirFFI::InPointer.from e, :bar
      ptr.address.must_equal 1
    end
  end
end

