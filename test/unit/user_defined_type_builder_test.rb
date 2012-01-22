require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

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
  end
end
