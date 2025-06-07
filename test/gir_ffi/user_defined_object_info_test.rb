# frozen_string_literal: true

require "gir_ffi_test_helper"
require "gir_ffi/user_defined_object_info"

GirFFI.setup :GIMarshallingTests

describe GirFFI::UserDefinedObjectInfo do
  describe "#described_class" do
    let(:info) { GirFFI::UserDefinedObjectInfo.new :some_class }

    it "returns the class passed to #initialize" do
      _(info.described_class).must_equal :some_class
    end
  end

  describe "#install_property" do
    let(:info) { GirFFI::UserDefinedObjectInfo.new :some_class }
    let(:foo_spec) { Object.new }

    it "adds the passed in property to the list of properties" do
      info.install_property foo_spec

      _(info.properties).must_equal [foo_spec]
    end
  end

  describe "#install_vfunc_implementation" do
    let(:info) { GirFFI::UserDefinedObjectInfo.new :some_class }
    let(:implementation) { Object.new }

    it "adds to the list of vfunc implementations" do
      _(info.vfunc_implementations).must_equal []
      info.install_vfunc_implementation :foo, implementation

      _(info.vfunc_implementations.map(&:name)).must_equal [:foo]
    end

    it "stores the passed-in implementation in the implementation object" do
      info.install_vfunc_implementation :foo, implementation
      impl = info.vfunc_implementations.first

      _(impl.implementation).must_equal implementation
    end

    it "provides a default implementation" do
      info.install_vfunc_implementation :foo
      impl = info.vfunc_implementations.first

      _(impl.implementation.class).must_equal Proc
    end
  end

  describe "#g_name" do
    let(:user_class) { Object.new }
    let(:info) { GirFFI::UserDefinedObjectInfo.new user_class }

    before do
      allow(user_class).to receive(:name).and_return "foo"
    end

    it "returns the described class' name by default" do
      _(info.g_name).must_equal "foo"
    end

    it "returns the the name set by #g_name= if present" do
      info.g_name = "bar"

      _(info.g_name).must_equal "bar"
    end
  end

  describe "#find_method" do
    let(:user_class) { Object.new }
    let(:info) { GirFFI::UserDefinedObjectInfo.new user_class }

    it "finds no methods" do
      _(info.find_method("foo")).must_be_nil
    end
  end

  describe "#find_signal" do
    let(:user_class) { Object.new }
    let(:info) { GirFFI::UserDefinedObjectInfo.new user_class }

    it "finds no signals" do
      _(info.find_signal("foo")).must_be_nil
    end
  end

  describe "#interfaces" do
    let(:modul) { GIMarshallingTests::Interface }
    let(:user_class) { Class.new GIMarshallingTests::Object }
    let(:info) { GirFFI::UserDefinedObjectInfo.new user_class }

    before do
      user_class.send :include, modul
    end

    it "returns the interface infos for the include modules" do
      _(info.interfaces).must_equal [modul.gir_info]
    end
  end
end
