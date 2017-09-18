# frozen_string_literal: true

require 'gir_ffi_test_helper'

GirFFI.setup :PangoFT2

# Tests generated methods and functions in the PangoFT2 namespace.
describe PangoFT2 do
  describe PangoFT2::FontMap do
    it 'has a working method #load_font' do
      font_map = PangoFT2::FontMap.new
      context = font_map.create_context
      font_description = Pango::FontDescription.new
      font_map.load_font context, font_description
    end
  end
end
