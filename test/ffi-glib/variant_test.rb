# frozen_string_literal: true

require "gir_ffi_test_helper"

describe GLib::Variant do
  describe "#new_string" do
    it "sinks the reference for resulting variant" do
      var = GLib::Variant.new_string("Foo")

      _(var.is_floating).must_equal false
    end
  end

  describe "#get_string" do
    it "returns just the contained string" do
      var = GLib::Variant.new_string("Foo")

      _(var.get_string).must_equal "Foo"
    end
  end
end
