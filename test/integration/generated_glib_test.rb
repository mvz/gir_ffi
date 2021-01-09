# frozen_string_literal: true

require "gir_ffi_test_helper"

# Tests generated classes, methods and functions in the GLib namespace.
describe GLib do
  it "has the constant SOURCE_REMOVE" do
    _(GLib::SOURCE_REMOVE).must_equal false
  end
end
