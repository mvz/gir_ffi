require 'gir_ffi_test_helper'

describe GObject do
  describe ".type_interfaces" do
    it "works, showing that returning an array of GType works" do
      klass = GObject::TypeModule
      ifcs = GObject.type_interfaces klass.get_gtype
      assert_equal 1, ifcs.size
    end
  end

  describe GObject::TypeInfo do
    let(:instance) { GObject::TypeInfo.new }
    it "has a working field setter for class_init" do
      instance.class_init = proc do |object_class, data|
      end
    end

    it "has a working field getter for class_init" do
      instance.class_init.must_be_nil
      instance.class_init = proc do |object_class, data|
      end
      result = instance.class_init
      result.wont_be_nil
      result.must_be_instance_of FFI::Function
    end
  end

  describe GObject::TypePlugin do
    it "is implemented as a module" do
      mod = GObject::TypePlugin
      assert_instance_of Module, mod
      refute_instance_of Class, mod
    end
  end

  describe GObject::TypeModule do
    it "has the GObject::TypePlugin module as an ancestor" do
      klass = GObject::TypeModule
      assert_includes klass.ancestors, GObject::TypePlugin
    end
  end

  describe GObject::ValueArray do
    it "uses the constructor provided by GObject" do
      instance = GObject::ValueArray.new 16
      instance.n_prealloced.must_equal 16
      instance.n_values.must_equal 0
    end
  end
end
