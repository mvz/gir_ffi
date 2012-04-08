# coding: utf-8
require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

require 'gir_ffi'

GirFFI.setup :Gdk
GirFFI.setup :Pango
Gdk.init []

# Tests generated methods and functions in the Pango namespace.
describe "Building classes in the Pango namespace" do
  describe "the relevant font map subtype" do
    it "is correctly generated" do
      ctx = Gdk.pango_context_get
      ctx.get_font_map
    end
  end
end

