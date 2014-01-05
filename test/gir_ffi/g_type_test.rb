require 'gir_ffi_test_helper'

require 'gir_ffi/g_type'

describe GirFFI::GType do
  let(:gobject_gtype) { GObject::Object.get_gtype }
  let(:gobject_type_query) { GObject.type_query gobject_gtype }

  describe "#to_i" do
    it "returns the integer gtype" do
      gt = GirFFI::GType.new(gobject_gtype)
      gt.to_i.must_equal gobject_gtype
    end
  end

  describe "#class_size" do
    it "returns the class size for object types" do
      gt = GirFFI::GType.new(gobject_gtype)
      gt.class_size.must_equal gobject_type_query.class_size
    end
  end

  describe "#instance_size" do
    it "returns the instance size for object types" do
      gt = GirFFI::GType.new(gobject_gtype)
      gt.instance_size.must_equal gobject_type_query.instance_size
    end
  end
end
