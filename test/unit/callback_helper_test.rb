require File.expand_path('../test_helper.rb', File.dirname(__FILE__))

describe GirFFI::CallbackHelper do
  describe ".map_single_callback_arg" do
    it "correctly maps a :struct type" do
      GirFFI.setup :GObject

      cl = GObject::Closure.new_simple GObject::Closure::Struct.size, nil

      cinfo = GirFFI::IRepository.default.find_by_name 'GObject', 'ClosureMarshal'
      ainfo = cinfo.args[0]

      r = GirFFI::CallbackHelper.map_single_callback_arg cl.to_ptr, ainfo

      assert_instance_of GObject::Closure, r
      assert_equal r.to_ptr, cl.to_ptr
    end
  end
end
