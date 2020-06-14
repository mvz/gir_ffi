# frozen_string_literal: true

require "gir_ffi_test_helper"

GirFFI.setup :Regress
GirFFI.setup :GIMarshallingTests

describe GirFFI::ObjectBase do
  let(:derived_class) { Class.new GirFFI::ObjectBase }

  describe ".wrap" do
    it "delegates conversion to the wrapped pointer" do
      expect(ptr = Object.new).to receive(:to_object).and_return "good-result"
      _(derived_class.wrap(ptr)).must_equal "good-result"
    end
  end

  describe ".to_ffi_type" do
    it "returns itself" do
      _(derived_class.to_ffi_type).must_equal derived_class
    end
  end

  describe ".object_class" do
    it "returns an object of the class struct type" do
      _(Regress::TestObj.object_class).must_be_instance_of Regress::TestObjClass
    end

    it "caches its result" do
      first = Regress::TestObj.object_class
      second = Regress::TestObj.object_class
      _(second).must_be :eql?, first
    end
  end

  describe "#included_interfaces" do
    let(:base_class) { GIMarshallingTests::Object }
    let(:derived_class) { Class.new(base_class) }

    before do
      derived_class.class_eval { include GIMarshallingTests::Interface }
    end

    it "finds the included interface" do
      _(derived_class.included_interfaces).must_equal [GIMarshallingTests::Interface]
    end
  end

  describe "#registered_ancestors" do
    let(:base_class) { GIMarshallingTests::Object }
    let(:derived_class) { Class.new(base_class) }

    before do
      derived_class.class_eval { include GIMarshallingTests::Interface }
    end

    it "finds the ancestor classes and included interface" do
      _(derived_class.registered_ancestors)
        .must_equal [derived_class,
                     GIMarshallingTests::Interface,
                     GIMarshallingTests::Object,
                     GObject::Object]
    end
  end
end
