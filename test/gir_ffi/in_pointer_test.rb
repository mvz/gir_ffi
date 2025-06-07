# frozen_string_literal: true

require "gir_ffi_test_helper"

require "gir_ffi/in_pointer"

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
        self::Enum = FFI::Enum.new [:foo, :bar, :baz], :qux
      end
      ptr = GirFFI::InPointer.from_array e, [:bar, :foo, :baz]

      _(ptr.read_array_of_int32(3)).must_equal [1, 0, 2]
    end

    it "handles struct types" do
      e = Class.new(GirFFI::StructBase) do
        self::Struct = Class.new(GirFFI::Struct) do
          layout :foo, :int32, :bar, :int32
        end
      end
      struct = e::Struct.allocate
      struct[:foo] = 42
      struct[:bar] = 24
      ptr = GirFFI::InPointer.from_array e, [struct]

      _(ptr).wont_be :==, struct.to_ptr
      new_struct = e::Struct.new ptr

      _(new_struct[:foo]).must_equal 42
      _(new_struct[:bar]).must_equal 24
    end

    it "handles typed pointers" do
      p1 = GirFFI::InPointer.from :gint32, 42
      p2 = GirFFI::InPointer.from :gint32, 24

      ptr = GirFFI::InPointer.from_array [:pointer, :gint32], [p1, p2]

      _(ptr.read_array_of_pointer(2)).must_equal [p1, p2]
    end

    it "handles pointer casting" do
      ptr = GirFFI::InPointer.from_array [:pointer, :gint32], [42, 24]

      _(ptr.read_array_of_pointer(2).map(&:address)).must_equal [42, 24]
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

    it "is an instance of FFI::MemoryPointer" do
      _(@result).must_be_instance_of FFI::MemoryPointer
    end

    it "is zero-terminated" do
      assert_equal 0, @result.get_int(8)
    end
  end

  describe "an instance created with .from_array :utf8" do
    before do
      @result = GirFFI::InPointer.from_array :utf8, %w[foo bar baz]
    end

    it "returns an array of pointers to strings" do
      ary = @result.read_array_of_pointer(3)

      assert_equal %w[foo bar baz], ary.map(&:read_string)
    end
  end

  describe "an instance created with .from_array :filename" do
    before do
      @result = GirFFI::InPointer.from_array :filename, %w[foo bar baz]
    end

    it "returns an array of pointers to strings" do
      ary = @result.read_array_of_pointer(3)

      assert_equal %w[foo bar baz], ary.map(&:read_string)
    end
  end

  describe "an instance created with .from :utf8" do
    before do
      @result = GirFFI::InPointer.from :utf8, "foo"
    end

    it "returns a pointer to the given string" do
      assert_equal "foo", @result.read_string
    end

    it "is an instance of FFI::MemoryPointer" do
      _(@result).must_be_instance_of FFI::MemoryPointer
    end
  end

  describe "an instance created with .from :guint32" do
    before do
      @result = GirFFI::InPointer.from :guint32, 12_345
    end

    it "returns a pointer with an address equal to the given value" do
      assert_equal 12_345, @result.address
    end

    it "is an instance of FFI::Pointer" do
      _(@result).must_be_instance_of FFI::Pointer
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

    it "returns a pointer to the value for type :gint64" do
      result = GirFFI::InPointer.from :gint64, -0x90000000

      assert_equal(-0x90000000, result.get_int64(0))
    end

    it "returns a pointer to the value for type :guint64" do
      result = GirFFI::InPointer.from :guint64, 0xf0000000

      assert_equal 0xf0000000, result.get_uint64(0)
    end

    it "returns a pointer to the value for type :gdouble" do
      result = GirFFI::InPointer.from :gdouble, 0.1

      assert_in_epsilon 0.1, result.read_double
    end

    it "returns a pointer to the value for type :gfloat" do
      result = GirFFI::InPointer.from :gfloat, 0.1

      assert_in_epsilon 0.1, result.read_float
    end

    it "handles enum types" do
      e = Module.new do
        extend GirFFI::EnumBase
        self::Enum = FFI::Enum.new [:foo, :bar, :baz], :qux
      end
      ptr = GirFFI::InPointer.from e, :bar

      _(ptr.address).must_equal 1
    end

    describe "for type :void" do
      it "returns the result of to_ptr" do
        obj = Object.new
        def obj.to_ptr
          :test_value
        end

        _(GirFFI::InPointer.from(:void, obj)).must_equal :test_value
      end

      it "returns nil when passed nil" do
        _(GirFFI::InPointer.from(:void, nil)).must_be_nil
      end
    end

    describe "for types that are classes" do
      it "returns the result of to_ptr" do
        klass = Class.new
        obj = klass.new
        def obj.to_ptr
          :test_value
        end

        _(GirFFI::InPointer.from(klass, obj)).must_equal :test_value
      end
    end
  end
end
