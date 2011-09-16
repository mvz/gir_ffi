require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

require 'ffi-gobject'

describe GObject::Value do
  describe "::wrap_ruby_value class" do
    it "wraps a boolean false" do
      gv = GObject::Value.wrap_ruby_value false
      assert_instance_of GObject::Value, gv
      assert_equal false, gv.get_boolean
    end

    it "wraps a boolean true" do
      gv = GObject::Value.wrap_ruby_value true
      assert_instance_of GObject::Value, gv
      assert_equal true, gv.get_boolean
    end
  end

  describe "#ruby_value" do
    it "unwraps a boolean false" do
      gv = GObject::Value.wrap_ruby_value false
      result = gv.ruby_value
      assert_equal false, result
    end

    it "unwraps a boolean true" do
      gv = GObject::Value.wrap_ruby_value true
      result = gv.ruby_value
      assert_equal true, result
    end
  end
end

