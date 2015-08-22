require 'gir_ffi_test_helper'

describe GObject::RubyClosure do
  it 'has a constructor with a mandatory block argument' do
    assert_raises ArgumentError do
      GObject::RubyClosure.new
    end
  end

  it 'is a kind of Closure' do
    c = GObject::RubyClosure.new {}
    assert_kind_of GObject::Closure, c
  end

  it 'is able to retrieve its block from its struct' do
    a = 0
    c = GObject::RubyClosure.new { a = 2 }
    c2 = GObject::RubyClosure.wrap(c.to_ptr)
    c2.invoke_block
    assert_equal 2, a
  end

  describe 'its #marshaller singleton method' do
    it "invokes its closure argument's block" do
      a = 0
      c = GObject::RubyClosure.new { a = 2 }
      GObject::RubyClosure.marshaller(c, nil, nil, nil, nil)
      assert_equal 2, a
    end

    it 'works when its closure argument is a GObject::Closure' do
      a = 0
      c = GObject::RubyClosure.new { a = 2 }
      c2 = GObject::Closure.wrap(c.to_ptr)
      GObject::RubyClosure.marshaller(c2, nil, nil, nil, nil)
      assert_equal 2, a
    end

    it "stores the closure's return value in the proper gvalue" do
      c = GObject::RubyClosure.new { 2 }
      gv = GObject::Value.new
      GObject::RubyClosure.marshaller(c, gv, nil, nil, nil)
      assert_equal 2, gv.get_value
    end
  end

  it 'has GObject::Closure#invoke call its block' do
    a = 0
    c = GObject::RubyClosure.new { a = 2 }
    c2 = GObject::Closure.wrap(c.to_ptr)
    c2.invoke nil, nil, nil
    assert_equal 2, a
  end
end
