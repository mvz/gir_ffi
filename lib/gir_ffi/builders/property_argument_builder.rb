# frozen_string_literal: true

require 'gir_ffi/builders/base_argument_builder'

module GirFFI
  module Builders
    # Convertor for arguments for property setters.
    class PropertyArgumentBuilder < BaseArgumentBuilder
      def pre_conversion
        pr = []
        pr << "#{call_argument_name} = #{ingoing_convertor.conversion}"
        pr
      end

      def ingoing_convertor
        if type_info.needs_ruby_to_c_conversion_for_properties?
          RubyToCConvertor.new(type_info, name)
        else
          NullConvertor.new(name)
        end
      end
    end
  end
end
