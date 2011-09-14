require File.expand_path('gir_ffi_test_helper.rb', File.dirname(__FILE__))

class ArgHelperTest < MiniTest::Spec
  context "The outptr_to_utf8_array method" do
    context "when called with a valid pointer to a string array" do
      setup do
	p = GirFFI::AllocationHelper.safe_malloc FFI.type_size(:pointer) * 2
	p.write_array_of_pointer ["one", "two"].map {|str|
	  len = str.bytesize
	  GirFFI::AllocationHelper.safe_malloc(len + 1).write_string(str).put_char(len, 0)
	}
	@ptr = GirFFI::AllocationHelper.safe_malloc FFI.type_size(:pointer)
	@ptr.write_pointer p
      end

      should "return the string array" do
	assert_equal ["one", "two"],
	  GirFFI::ArgHelper.outptr_to_utf8_array(@ptr, 2)
      end
    end

    context "when called with a pointer to a string array containing a null pointer" do
      setup do
	ptrs = ["one", "two"].map {|str|
	  len = str.bytesize
	  GirFFI::AllocationHelper.safe_malloc(len + 1).write_string(str).put_char(len, 0)
	}
	ptrs << nil
	p = GirFFI::AllocationHelper.safe_malloc FFI.type_size(:pointer) * 3
	p.write_array_of_pointer ptrs
	@ptr = GirFFI::AllocationHelper.safe_malloc FFI.type_size(:pointer)
	@ptr.write_pointer p
      end

      should "render the null pointer as nil" do
	assert_equal ["one", "two", nil],
	  GirFFI::ArgHelper.outptr_to_utf8_array(@ptr, 3)
      end
    end

    context "when called with a pointer to null" do
      should "return nil" do
	ptr = GirFFI::InOutPointer.for :pointer
        assert ptr.read_pointer.null?
	assert_nil GirFFI::ArgHelper.outptr_to_utf8_array(ptr, 0)
      end
    end
  end

  context "The object_to_inptr method" do
    context "when called with an object implementing to_ptr" do
      should "return the result of to_ptr" do
	obj = Object.new
	def obj.to_ptr; :test_value; end
	assert_equal :test_value, GirFFI::ArgHelper.object_to_inptr(obj)
      end
    end

    context "when called with nil" do
      should "return nil" do
	assert_equal nil, GirFFI::ArgHelper.object_to_inptr(nil)
      end
    end
  end

  context "The object_pointer_to_object method" do
    setup do
      GirFFI.setup :Regress
      @o = Regress::TestSubObj.new
      @o2 = GirFFI::ArgHelper.object_pointer_to_object @o.to_ptr
    end

    should "return an object of the correct class" do
      assert_instance_of Regress::TestSubObj, @o2
    end

    should "return an object pointing to the original struct" do
      assert_equal @o.to_ptr, @o2.to_ptr
    end
  end

end
