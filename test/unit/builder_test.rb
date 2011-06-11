require File.expand_path('../test_helper.rb', File.dirname(__FILE__))

describe GirFFI::Builder do
  describe ".itypeinfo_to_callback_ffitype" do
    it "correctly maps a :union argument to :pointer" do
      stub(iface = Object.new).info_type { :union }
      stub(info = Object.new).interface { iface }
      stub(info).tag { :interface }
      stub(info).pointer? { false }

      result = GirFFI::Builder.itypeinfo_to_callback_ffitype info

      assert_equal :pointer, result
    end
  end
end

