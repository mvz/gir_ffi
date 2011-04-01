require File.expand_path('test_helper.rb', File.dirname(__FILE__))

class ArgHelperTest < Test::Unit::TestCase
  context "The int_to_inoutptr method's return value" do
    setup do
      @result = GirFFI::ArgHelper.int_to_inoutptr 24
    end

    should "be an FFI::Pointer" do
      assert_instance_of FFI::Pointer, @result
    end

    should "hold a pointer to the correct input value" do
      assert_equal 24, @result.read_int
    end
  end

  context "The utf8_array_to_inoutptr method" do
    context "when called with an array of strings" do
      setup do
	@result = GirFFI::ArgHelper.utf8_array_to_inoutptr ["foo", "bar", "baz"]
      end

      should "return an FFI::Pointer" do
	assert_instance_of FFI::Pointer, @result
      end

      should "return a pointer to an array of pointers to strings" do
	ptr = @result.read_pointer
	ary = ptr.read_array_of_pointer(3)
	assert_equal ["foo", "bar", "baz"], ary.map {|p| p.read_string}
      end
    end
    context "when called with nil" do
      should "return nil" do
	assert_nil GirFFI::ArgHelper.utf8_array_to_inoutptr nil
      end
    end
  end

  context "The outptr_to_int method" do
    setup do
      @ptr = GirFFI::AllocationHelper.safe_malloc FFI.type_size(:int)
      @ptr.write_int 342
    end

    should "retrieve the correct integer value" do
      assert_equal 342, GirFFI::ArgHelper.outptr_to_int(@ptr)
    end
  end

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
	ptr = GirFFI::ArgHelper.pointer_pointer.write_pointer nil
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

  context "The pointer_outptr method" do
    should "return a pointer to a null pointer" do
      ptr = GirFFI::ArgHelper.pointer_outptr
      pptr = ptr.read_pointer
      assert pptr.null?
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

  if false
  context "The map_single_callback_arg method" do
    should "correctly map a :struct type" do
      GirFFI.setup :GObject

      cl = GObject::Closure.new_simple GObject::Closure::Struct.size, nil

      cinfo = GirFFI::IRepository.default.find_by_name 'GObject', 'ClosureMarshal'
      ainfo = cinfo.args[0]

      r = GirFFI::ArgHelper.map_single_callback_arg cl.to_ptr, ainfo

      assert_instance_of GObject::Closure, r
      assert_equal r.to_ptr, cl.to_ptr
    end
  end
  end
end
