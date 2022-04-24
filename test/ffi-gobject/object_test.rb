# frozen_string_literal: true

require "gir_ffi_test_helper"

require "ffi-gobject"
GirFFI.setup :GIMarshallingTests

describe GObject::Object do
  describe ".new" do
    it "is overridden to take only one argument" do
      _(GObject::Object.new({})).must_be_instance_of GObject::Object
    end

    it "can be used to create objects with properties" do
      obj = GIMarshallingTests::SubObject.new(int: 13)
      _(obj.int).must_equal 13
    end

    it "allows omission of the first argument" do
      _(GObject::Object.new).must_be_instance_of GObject::Object
    end

    it "raises an error for properties that do not exist" do
      _(proc { GObject::Object.new(dog: "bark") }).must_raise GirFFI::PropertyNotFoundError
    end
  end

  describe "#get_property" do
    it "is overridden to have arity 1" do
      _(GObject::Object.instance_method(:get_property).arity).must_equal 1
    end

    it "raises an error for a property that does not exist" do
      instance = GObject::Object.new
      _(proc { instance.get_property "foo-bar" }).must_raise GirFFI::PropertyNotFoundError
    end

    it "raises an error for a property that does not exist" do
      instance = GObject::Object.new
      _(proc { instance.get_property "foo-bar" })
        .must_raise GirFFI::PropertyNotFoundError
    end
  end

  describe "#set_property" do
    it "raises an error for a property that does not exist" do
      instance = GObject::Object.new
      _(proc { instance.set_property "foo-bar", 123 })
        .must_raise GirFFI::PropertyNotFoundError
    end
  end

  describe "#signal_connect" do
    subject { GObject::Object.new }

    it "delegates to GObject" do
      expect(GObject).to receive(:signal_connect).with(subject, "some-event", nil)
      subject.signal_connect("some-event") do
        nothing
      end
    end

    it "delegates to GObject if an optional data argument is passed" do
      expect(GObject).to receive(:signal_connect).with(subject, "some-event", "data")
      subject.signal_connect("some-event", "data") do
        nothing
      end
    end
  end

  describe "#signal_connect_after" do
    subject { GObject::Object.new }

    it "delegates to GObject" do
      expect(GObject).to receive(:signal_connect_after).with(subject, "some-event", nil)
      subject.signal_connect_after("some-event") do
        nothing
      end
    end

    it "delegates to GObject if an optional data argument is passed" do
      expect(GObject).to receive(:signal_connect_after).with(subject, "some-event", "data")
      subject.signal_connect_after("some-event", "data") do
        nothing
      end
    end
  end

  describe "upon garbage collection" do
    it "lowers the reference count" do
      obj = GObject::Object.new
      GObject::Lib.g_object_ref obj.to_ptr
      _(object_ref_count(obj)).must_equal 2
      GObject::Object.send :finalize, obj.to_ptr
      _(object_ref_count(obj)).must_equal 1
    end
  end
end
