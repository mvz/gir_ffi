# coding: utf-8
require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

require 'gir_ffi'

GirFFI.setup :Gdk
GirFFI.setup :Pango
Gdk.init []

# Tests generated methods and functions in the Pango namespace.
describe "Building classes in the Pango namespace" do
  describe "the relevant Pango::FontMap subclass" do
    it "is a descendant from Pango::FontMap" do
      ctx = Gdk.pango_context_get
      result = ctx.get_font_map
      result.class.ancestors.must_include Pango::FontMap
    end
  end
end

