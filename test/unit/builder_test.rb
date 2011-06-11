require File.expand_path('../test_helper.rb', File.dirname(__FILE__))

describe GirFFI::Builder do
  describe ".itypeinfo_to_callback_ffitype" do
    describe "for an :interface argument" do
      setup do
        @iface = Object.new
        stub(@info = Object.new).interface { @iface }
        stub(@info).tag { :interface }
        stub(@info).pointer? { false }
      end

      it "correctly maps a :union argument to :pointer" do
        stub(@iface).info_type { :union }

        result = GirFFI::Builder.itypeinfo_to_callback_ffitype @info

        assert_equal :pointer, result
      end

      it "correctly maps a :flags argument to :int32" do
        stub(@iface).info_type { :flags }

        result = GirFFI::Builder.itypeinfo_to_callback_ffitype @info

        assert_equal :int32, result
      end
    end
  end
end

