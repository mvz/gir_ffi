require 'gir_ffi_test_helper'

GirFFI.setup :GIMarshallingTests

describe GirFFI::Builders::UserDefinedBuilder do
  let(:klass) { Object.const_set("DerivedClass#{Sequence.next}",
                                 Class.new(GIMarshallingTests::Object)) }
  let(:builder) { GirFFI::Builders::UserDefinedBuilder.new info }

  before do
    builder.build_class
  end

  describe "with type info containing one property" do
    let(:info) { GirFFI::UserDefinedTypeInfo.new klass do |info|
      info.install_property GObject.param_spec_int("foo", "foo bar",
                                                   "The Foo Bar Property",
                                                   10, 20, 15,
                                                   3)
    end }

    it "registers a type that is bigger than the parent" do
      gtype = klass.get_gtype
      q = GObject.type_query gtype
      q.instance_size.must_be :>, GIMarshallingTests::Object::Struct.size
    end

    it "gives the types Struct the fields :parent and :foo" do
      klass::Struct.members.must_equal [:parent, :foo]
    end

    it "creates accessor functions for the property" do
      obj = klass.new
      obj.foo = 13
      obj.foo.must_equal 13
    end

    it "makes the property retrievable using #get_property" do
      obj = klass.new
      obj.foo = 13
      obj.get_property("foo").get_value.must_equal 13
    end

    it "makes the property settable using #set_property" do
      obj = klass.new
      obj.set_property("foo", 20)
      obj.foo.must_equal 20
    end
  end

  describe "with type info containing an overridden g_name" do
    let(:info) { GirFFI::UserDefinedTypeInfo.new klass do |info|
      info.g_name = "OtherName#{Sequence.next}"
    end }

    it "registers a type under the overridden name" do
      registered_name = GObject.type_name(klass.get_gtype)
      registered_name.must_equal info.g_name
      registered_name.wont_equal klass.name
    end
  end

  describe "with type info containing a vfunc" do
    let(:info) { GirFFI::UserDefinedTypeInfo.new klass do |info|
      info.install_vfunc_implementation :method_int8_in, proc {|instance, in_|
        instance.int = in_ }
    end }

    it "allows the vfunc to be called through its invoker" do
      obj = klass.new
      obj.method_int8_in 12
      obj.int.must_equal 12
    end
  end

  describe "#find_vfunc" do
    let(:info) { GirFFI::UserDefinedTypeInfo.new klass }

    it "finds vfuncs in the superclass" do
      result = builder.find_vfunc :method_int8_in
      result.name.must_equal "method_int8_in"
      result.must_be_instance_of GObjectIntrospection::IVFuncInfo
    end
  end
end
