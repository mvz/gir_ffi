# coding: utf-8
require 'gir_ffi_test_helper'

require 'gir_ffi'

GirFFI.setup :Pango

# Tests generated methods and functions in the Pango namespace.
describe Pango do
  describe Pango::Language do
    it "has a working method get_scripts" do
      lang = Pango::Language.from_string 'ja'
      result = lang.get_scripts

      if GLib::SizedArray === result
        scripts = result
      else
        ptr, size = *result
        scripts = GLib::SizedArray.new Pango::Script, size, ptr
      end

      scripts.to_a.must_equal [:han, :katakana, :hiragana]
    end
  end
end
