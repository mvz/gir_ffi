require 'gir_ffi_test_helper'

describe GObject::RubyClosure do
  should "have a constructor with a mandatory block argument" do
    assert_raises ArgumentError do
      GObject::RubyClosure.new
    end
  end

  should "be a kind of Closure" do
    c = GObject::RubyClosure.new {}
    assert_kind_of GObject::Closure, c
  end

  should "be able to retrieve its block from its struct" do
    a = 0
    c = GObject::RubyClosure.new { a = 2 }
    c2 = GObject::RubyClosure.wrap(c.to_ptr)
    c2.block.call
    assert_equal 2, a
  end

  describe "its #marshaller singleton method" do
    should "invoke its closure argument's block" do
      a = 0
      c = GObject::RubyClosure.new { a = 2 }
      GObject::RubyClosure.marshaller(c, nil, 0, nil, nil, nil)
      assert_equal 2, a
    end

    should "work when its closure argument is a GObject::Closure" do
      a = 0
      c = GObject::RubyClosure.new { a = 2 }
      c2 = GObject::Closure.wrap(c.to_ptr)
      GObject::RubyClosure.marshaller(c2, nil, 0, nil, nil, nil)
      assert_equal 2, a
    end

    should "store the closure's return value in the proper gvalue" do
      c = GObject::RubyClosure.new { 2 }
      gv = GObject::Value.new
      GObject::RubyClosure.marshaller(c, gv, 0, nil, nil, nil)
      assert_equal 2, gv.get_value
    end
  end

  should "have GObject::Closure#invoke call its block" do
    a = 0
    c = GObject::RubyClosure.new { a = 2 }
    c2 = GObject::Closure.wrap(c.to_ptr)
    c2.invoke nil, nil, nil
    assert_equal 2, a
  end
end
