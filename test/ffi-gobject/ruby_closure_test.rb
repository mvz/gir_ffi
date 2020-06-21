# frozen_string_literal: true

require "gir_ffi_test_helper"

describe GObject::RubyClosure do
  describe ".new" do
    it "takes a mandatory block argument" do
      assert_raises ArgumentError do
        GObject::RubyClosure.new
      end
    end

    it "returns a kind of Closure" do
      c = GObject::RubyClosure.new {}
      assert_kind_of GObject::Closure, c
    end
  end

  describe ".wrap" do
    it "returns a fully functional object that can invoke the original block" do
      a = 0
      c = GObject::RubyClosure.new { a = 2 }
      c2 = GObject::RubyClosure.wrap(c.to_ptr)
      c2.invoke_block
      assert_equal 2, a
    end
  end

  describe ".marshaller" do
    it "invokes its closure argument's block" do
      a = 0
      c = GObject::RubyClosure.new { a = 2 }
      GObject::RubyClosure.marshaller(c, nil, nil, nil, nil)
      assert_equal 2, a
    end

    it "works when its closure argument is a GObject::Closure" do
      a = 0
      c = GObject::RubyClosure.new { a = 2 }
      c2 = GObject::Closure.wrap(c.to_ptr)
      GObject::RubyClosure.marshaller(c2, nil, nil, nil, nil)
      assert_equal 2, a
    end

    it "stores the closure's return value in the proper gvalue" do
      c = GObject::RubyClosure.new { 2 }
      gv = GObject::Value.new.init GObject::TYPE_INT
      GObject::RubyClosure.marshaller(c, gv, nil, nil, nil)
      assert_equal 2, gv.get_value
    end
  end

  describe "#invoke" do
    it "invokes the ruby block" do
      a = 0
      c = GObject::RubyClosure.new { a = 2 }
      c2 = GObject::Closure.wrap(c.to_ptr)
      c2.invoke nil, []
      assert_equal 2, a
    end
  end
end
