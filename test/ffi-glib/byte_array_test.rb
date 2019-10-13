# frozen_string_literal: true

require "gir_ffi_test_helper"

describe GLib::ByteArray do
  it "can succesfully be created with GLib::ByteArray.new" do
    ba = GLib::ByteArray.new
    assert_instance_of GLib::ByteArray, ba
  end

  it "allows strings to be appended to it" do
    ba = GLib::ByteArray.new
    ba.append "abdc"
    pass
  end

  it "has a working #to_string method" do
    ba = GLib::ByteArray.new
    ba = ba.append "abdc"
    assert_equal "abdc", ba.to_string
  end

  it "can be created from a string" do
    str = "cdba"
    ba = GLib::ByteArray.from str
    _(ba.to_string).must_equal str
  end
end
