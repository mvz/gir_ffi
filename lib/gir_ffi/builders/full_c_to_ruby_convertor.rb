# frozen_string_literal: true

require "gir_ffi/builders/c_to_ruby_convertor"

module GirFFI
  module Builders
    # Builder that generates code to convert values from C to Ruby, including
    # GValue unpacking. Used by argument builders.
    class FullCToRubyConvertor < CToRubyConvertor
      def conversion
        if @type_info.gvalue?
          "GObject::Value.wrap(#{@argument}).get_value"
        else
          super
        end
      end
    end
  end
end
