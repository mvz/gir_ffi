require 'gir_ffi_test_helper'

GirFFI.setup :GIMarshallingTests

describe GirFFI::Builder::Type::UserDefined do
  describe "with a block with a call to #install_property" do
    before do
      @klass = Class.new GIMarshallingTests::OverridesObject
      Object.const_set "Derived#{Sequence.next}", @klass
      @builder = GirFFI::Builder::Type::UserDefined.new @klass do
        install_property GObject.param_spec_int("foo", "foo bar",
                                                "The Foo Bar Property",
                                                10, 20, 15,
                                                3)
      end
      @builder.build_class
    end

    it "has one property of type GirFFI::UserDefined::IPropertyInfo" do
      props = @builder.send(:properties)
      props.length.must_equal 1
      props[0].must_be_instance_of GirFFI::UserDefined::IPropertyInfo
    end

    describe "the info attribute" do
      before do
        @info = @builder.info
      end

      it "is an object of type GirFFI::UserDefined::IObjectInfo" do
        @info.must_be_instance_of GirFFI::UserDefined::IObjectInfo
      end

      it "knows about the single property :foo" do
        props = @info.properties
        props.length.must_equal 1
        foo_property = props[0]
        foo_property.must_be_instance_of GirFFI::UserDefined::IPropertyInfo
        foo_property.name.must_equal "foo"
      end
    end
  end
end
