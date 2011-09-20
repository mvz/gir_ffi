require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

require 'ffi-gobject'

describe GObject do
  it "has type_init as a public method" do
    assert GObject.respond_to?('type_init')
  end

  it "does not have g_type_init as a public method" do
    assert GObject.respond_to?('g_type_init') == false
  end

  context "::type_init" do
    it "does not raise an error" do
      assert_nothing_raised do
        GObject.type_init
      end
    end
  end
end

