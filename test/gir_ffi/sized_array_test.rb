# frozen_string_literal: true

require "gir_ffi_test_helper"

describe GirFFI::SizedArray do
  describe "::wrap" do
    it "takes a type, size and pointer and returns a GirFFI::SizedArray wrapping them" do
      expect(ptr = Object.new).to receive(:null?).and_return false
      sarr = GirFFI::SizedArray.wrap :gint32, 3, ptr

      assert_instance_of GirFFI::SizedArray, sarr
      assert_equal ptr, sarr.to_ptr
      assert_equal 3, sarr.size
      assert_equal :gint32, sarr.element_type
    end

    it "returns nil if the wrapped pointer is null" do
      expect(ptr = Object.new).to receive(:null?).and_return true
      sarr = GirFFI::SizedArray.wrap :gint32, 3, ptr
      _(sarr).must_be_nil
    end
  end

  describe "#each" do
    it "yields each element" do
      ary = %w[one two three]
      ptrs = ary.map { |a| FFI::MemoryPointer.from_string(a) }
      ptrs << nil
      block = FFI::MemoryPointer.new(:pointer, ptrs.length)
      block.write_array_of_pointer ptrs

      sarr = GirFFI::SizedArray.new :utf8, 3, block
      arr = []
      sarr.each do |str|
        arr << str
      end

      assert_equal %w[one two three], arr
    end
  end

  describe "::from" do
    describe "from a Ruby array" do
      it "creates a GirFFI::SizedArray with the same elements" do
        arr = GirFFI::SizedArray.from :gint32, 3, [3, 2, 1]
        _(arr).must_be_instance_of GirFFI::SizedArray

        assert_equal [3, 2, 1], arr.to_a
      end

      it "raises an error if the array has the wrong number of elements" do
        _(proc { GirFFI::SizedArray.from :gint32, 4, [3, 2, 1] }).must_raise ArgumentError
      end

      it "uses the array's size if passed -1 as the size" do
        arr = GirFFI::SizedArray.from :gint32, -1, [3, 2, 1]
        _(arr.size).must_equal 3
      end
    end

    describe "from a Ruby string" do
      it "creates a GirFFI::SizedArray with elements corresponding to the string's bytes" do
        arr = GirFFI::SizedArray.from :guint8, 3, "foo"
        _(arr).must_be_instance_of GirFFI::SizedArray

        assert_equal "foo".bytes, arr.to_a
      end
    end

    describe "from a GirFFI::SizedArray" do
      it "return its argument" do
        arr = GirFFI::SizedArray.from :gint32, 3, [3, 2, 1]
        arr2 = GirFFI::SizedArray.from :gint32, 3, arr

        assert_equal arr, arr2
      end

      it "raises an error if the argument has the wrong number of elements" do
        arr = GirFFI::SizedArray.from :gint32, 3, [3, 2, 1]
        _(proc { GirFFI::SizedArray.from :gint32, 4, arr }).must_raise ArgumentError
      end
    end

    it "returns nil when passed nil" do
      arr = GirFFI::SizedArray.from :gint32, 0, nil
      _(arr).must_be_nil
    end

    it "wraps its argument if given a pointer" do
      arr = GirFFI::SizedArray.from :gint32, 3, [3, 2, 1]
      arr2 = GirFFI::SizedArray.from :gint32, 3, arr.to_ptr

      assert_instance_of GirFFI::SizedArray, arr2
      refute_same arr2, arr
      _(arr2.to_ptr).must_equal arr.to_ptr
    end
  end

  describe ".copy_from" do
    describe "from a Ruby array" do
      it "creates an unowned GirFFI::SizedArray with the same elements" do
        arr = GirFFI::SizedArray.copy_from :gint32, 3, [3, 2, 1]
        _(arr).must_be_instance_of GirFFI::SizedArray

        assert_equal [3, 2, 1], arr.to_a
        _(arr.to_ptr).wont_be :autorelease?
      end

      it "creates unowned copies of struct pointer elements" do
        struct = GIMarshallingTests::BoxedStruct.new
        struct.long_ = 2342
        _(struct.struct).must_be :owned?

        arr = GirFFI::SizedArray.copy_from([:pointer, GIMarshallingTests::BoxedStruct],
                                           1,
                                           [struct])
        _(arr).must_be_instance_of GirFFI::SizedArray
        _(arr.to_ptr).wont_be :autorelease?

        struct_copy = arr.first
        _(struct_copy.long_).must_equal struct.long_
        _(struct_copy.to_ptr).wont_be :==, struct.to_ptr
        _(struct_copy.struct).wont_be :owned?
      end

      it "increases the ref count of object pointer elements" do
        obj = GIMarshallingTests::Object.new 42
        arr = GirFFI::SizedArray.copy_from([:pointer, GIMarshallingTests::Object],
                                           -1,
                                           [obj, nil])
        _(arr).must_be_instance_of GirFFI::SizedArray
        _(arr.to_ptr).wont_be :autorelease?

        _(arr.to_a).must_equal [obj, nil]
        _(object_ref_count(obj)).must_equal 2
      end
    end

    describe "from a GirFFI::SizedArray" do
      it "return an unowned copy of its argument" do
        arr = GirFFI::SizedArray.from :gint32, 3, [3, 2, 1]
        arr2 = GirFFI::SizedArray.copy_from :gint32, 3, arr
        _(arr.to_ptr).wont_be :==, arr2.to_ptr
        _(arr2.to_a).must_equal [3, 2, 1]
        _(arr2.to_ptr).wont_be :autorelease?
      end
    end

    it "returns nil when passed nil" do
      arr = GirFFI::SizedArray.copy_from :gint32, 0, nil
      _(arr).must_be_nil
    end
  end

  describe "#==" do
    it "returns true when comparing to an array with the same elements" do
      sized = GirFFI::SizedArray.from :int32, 3, [1, 2, 3]

      _(sized).must_be :==, [1, 2, 3]
    end

    it "returns false when comparing to an array with different elements" do
      sized = GirFFI::SizedArray.from :int32, 3, [1, 2, 3]

      _(sized).wont_be :==, [1, 2]
    end

    it "returns true when comparing to a sized array with the same elements" do
      sized = GirFFI::SizedArray.from :int32, 3, [1, 2, 3]
      other = GirFFI::SizedArray.from :int32, 3, [1, 2, 3]

      _(sized).must_be :==, other
    end

    it "returns false when comparing to a sized array with different elements" do
      sized = GirFFI::SizedArray.from :int32, 3, [1, 2, 3]
      other = GirFFI::SizedArray.from :int32, 2, [1, 2]

      _(sized).wont_be :==, other
    end
  end

  describe "#size_in_bytes" do
    it "returns the correct value" do
      sized = GirFFI::SizedArray.from :int32, 3, [1, 2, 3]

      _(sized.size_in_bytes).must_equal 12
    end
  end

  describe ".get_value_from_pointer" do
    it "returns just a pointer" do
      sized = GirFFI::SizedArray.from :int32, 3, [1, 2, 3]
      ptr = sized.to_ptr
      result = GirFFI::SizedArray.get_value_from_pointer(ptr, 0)
      _(result).must_be :==, ptr
    end

    it "offsets correctly" do
      sized = GirFFI::SizedArray.from :int32, 3, [1, 2, 3]
      ptr = sized.to_ptr
      next_ptr = GirFFI::SizedArray.get_value_from_pointer(ptr, 4)
      tail = GirFFI::SizedArray.from(:int32, 2, next_ptr)
      _(tail).must_be :==, [2, 3]
    end
  end

  describe ".copy_value_to_pointer" do
    it "copies data correctly" do
      sized = GirFFI::SizedArray.from :int32, 3, [1, 2, 3]
      target = FFI::MemoryPointer.new sized.size_in_bytes
      GirFFI::SizedArray.copy_value_to_pointer(sized, target)
      result = GirFFI::SizedArray.from :int32, 3, target
      _(result).must_be :==, [1, 2, 3]
    end
  end

  describe "creating and reading back" do
    it "works for an array of strings" do
      arr = GirFFI::SizedArray.from :utf8, 3, %w[foo bar baz]
      _(arr).must_be_instance_of GirFFI::SizedArray
      _(arr.to_a).must_equal %w[foo bar baz]
    end

    it "works for an array of filenames" do
      arr = GirFFI::SizedArray.from :filename, 3, %w[foo bar baz]
      _(arr).must_be_instance_of GirFFI::SizedArray
      _(arr.to_a).must_equal %w[foo bar baz]
    end

    it "works for an array of enums" do
      arr = GirFFI::SizedArray.from Regress::TestEnum, -1, [:value2, :value3, :value4]
      _(arr).must_be_instance_of GirFFI::SizedArray
      _(arr.to_a).must_equal [:value2, :value3, :value4]
    end

    it "works for an array of objects" do
      obj = Regress::TestObj.constructor
      arr = GirFFI::SizedArray.from Regress::TestObj, -1, [obj]
      _(arr).must_be_instance_of GirFFI::SizedArray
      _(arr.to_a).must_equal [obj]
    end

    it "works for an array of interface implementations" do
      value = Gio.file_new_for_path("/")
      arr = GirFFI::SizedArray.from Gio::File, -1, [value]
      _(arr).must_be_instance_of GirFFI::SizedArray
      _(arr.to_a).must_equal [value]
    end
  end

  it "includes Enumerable" do
    _(GirFFI::SizedArray).must_include Enumerable
  end
end
