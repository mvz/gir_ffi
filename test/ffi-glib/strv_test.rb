require 'base_test_helper'

describe GLib::Strv do
  describe "::from" do
    it "creates a Strv from a Ruby array" do
      strv = GLib::Strv.from %w(1 2 3)
      strv.must_be_instance_of GLib::Strv
      strv.to_a.must_equal %w(1 2 3)
    end

    it "return its argument if given a Strv" do
      strv = GLib::Strv.from %w(1 2 3)
      strv2 = GLib::Strv.from strv
      assert strv2.equal? strv
    end

    it "wraps its argument if given a pointer" do
      strv = GLib::Strv.from %w(1 2 3)

      pointer = strv.to_ptr
      pointer.must_be_kind_of FFI::Pointer

      strv2 = GLib::Strv.from pointer

      strv2.must_be_kind_of GLib::Strv
      refute strv2.equal? strv
      strv2.to_a.must_equal strv.to_a
    end
  end

  describe "#==" do
    it "returns true when comparing to an array with the same elements" do
      strv = GLib::Strv.from %w(1 2 3)

      strv.must_be :==, %w(1 2 3)
    end

    it "returns false when comparing to an array with different elements" do
      strv = GLib::Strv.from %w(1 2 3)

      strv.wont_be :==, %w(1 2)
    end

    it "returns true when comparing to a strv with the same elements" do
      strv = GLib::Strv.from %w(1 2 3)
      other = GLib::Strv.from %w(1 2 3)

      strv.must_be :==, other
    end

    it "returns false when comparing to a strv with different elements" do
      strv = GLib::Strv.from %w(1 2 3)
      other = GLib::Strv.from %w(1 2)

      strv.wont_be :==, other
    end
  end
end
