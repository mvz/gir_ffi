require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

require 'ffi-gobject'

describe GObject::Object do
  describe "#get_property" do
    it "is overridden to have arity 1" do
      assert_equal 1,
        GObject::Object.instance_method("get_property").arity
    end

    it 'includes GObject::RubyStyle' do
      assert GObject::Object.included_modules.include?(GObject::RubyStyle)
    end
  end
end
