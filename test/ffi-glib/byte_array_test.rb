# frozen_string_literal: true

require "gir_ffi_test_helper"

describe GLib::ByteArray do
  it "can succesfully be created with GLib::ByteArray.new" do
    ba = GLib::ByteArray.new

    assert_instance_of GLib::ByteArray, ba
  end

  describe "#append" do
    it "allows strings to be appended" do
      ba = GLib::ByteArray.new
      ba.append "abdc"
      pass
    end

    it "returns self" do
      ba = GLib::ByteArray.new
      result = ba.append "abdc"

      _(result.object_id).must_equal ba.object_id
    end
  end

  it "has a working #to_string method" do
    ba = GLib::ByteArray.new
    ba.append "abdc"

    assert_equal "abdc", ba.to_string
  end

  it "can be created from a string" do
    str = "cdba"
    ba = GLib::ByteArray.from str

    _(ba.to_string).must_equal str
  end
end
