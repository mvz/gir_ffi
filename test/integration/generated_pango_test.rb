# coding: utf-8
require 'gir_ffi_test_helper'

GirFFI.setup :Pango

# Tests generated methods and functions in the Pango namespace.
describe Pango do
  describe Pango::Language do
    it 'has a working method #get_scripts' do
      lang = Pango::Language.from_string 'ja'
      result = lang.get_scripts

      if result.is_a? GirFFI::SizedArray
        scripts = result
      else
        ptr, size = *result
        scripts = GirFFI::SizedArray.new Pango::Script, size, ptr
      end

      scripts.must_be :==, [:han, :katakana, :hiragana]
    end
  end
end
