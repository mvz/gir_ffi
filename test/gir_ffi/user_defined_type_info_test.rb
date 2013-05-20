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
    it "takes a block that is evaluated in the context of the instance" do
      mock(foo_spec = Object.new).get_name { :foo }
      mock(bar_spec = Object.new).get_name { :bar }

      info = GirFFI::UserDefinedTypeInfo.new :some_class do
        install_property foo_spec
        install_property bar_spec
      end
      info.properties.map(&:name).must_equal [:foo, :bar]
    end
  end
end
