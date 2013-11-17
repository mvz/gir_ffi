require 'gir_ffi_test_helper'
require 'gir_ffi/user_defined_type_info'

describe GirFFI::UserDefinedTypeInfo do
  describe "#described_class" do
    it "returns the class passed to #initialize" do
      info = GirFFI::UserDefinedTypeInfo.new :some_class
      info.described_class.must_equal :some_class
    end
  end

  describe "#install_property" do
    it "adds the passed in property to the list of properties" do
      mock(foo_spec = Object.new).get_name { :foo }

      info = GirFFI::UserDefinedTypeInfo.new :some_class
      info.install_property foo_spec
      info.properties.map(&:name).must_equal [:foo]
    end
  end

  describe "#initialize" do
    it "yields the new object to the block passed" do
      mock(foo_spec = Object.new).get_name { :foo }
      mock(bar_spec = Object.new).get_name { :bar }

      info = GirFFI::UserDefinedTypeInfo.new :some_class do |inf|
        inf.install_property foo_spec
        inf.install_property bar_spec
      end
      info.properties.map(&:name).must_equal [:foo, :bar]
    end
  end

  describe "#g_name" do
    it "returns the described class' name by default" do
      mock(klass = Object.new).name { "foo" }
      info = GirFFI::UserDefinedTypeInfo.new klass
      info.g_name.must_equal "foo"
    end

    it "returns the the name set by #g_name= if present" do
      stub(klass = Object.new).name { "foo" }
      info = GirFFI::UserDefinedTypeInfo.new klass
      info.g_name = "bar"
      info.g_name.must_equal "bar"
    end
  end
end
