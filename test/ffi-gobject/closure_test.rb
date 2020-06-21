# frozen_string_literal: true

require "gir_ffi_test_helper"

describe GObject::Closure do
  describe ".new" do
    it "updates the ref_count of the created object" do
      # Tested on a subclass ...
      c = GObject::RubyClosure.new {}
      _(c.ref_count).must_equal 1
    end
  end

  describe "#invoke" do
    it "invokes the closure" do
      a = 0
      c = GObject::RubyClosure.new { a = 2 }
      c2 = GObject::Closure.wrap(c.to_ptr)
      c2.invoke nil, []
      _(a).must_equal 2
    end

    it "returns the closure result" do
      c = GObject::RubyClosure.new { 3 }
      c2 = GObject::Closure.wrap(c.to_ptr)
      result = c2.invoke GObject::Value.for_gtype(GObject::TYPE_INT), []
      _(result).must_equal 3
    end

    it "passes arguments" do
      a = 0
      c = GObject::RubyClosure.new { |val| a = val }
      c2 = GObject::Closure.wrap(c.to_ptr)
      c2.invoke nil, [5]
      _(a).must_equal 5
    end
  end
end
