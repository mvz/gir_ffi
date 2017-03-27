# frozen_string_literal: true

require 'gir_ffi/builders/registered_type_builder'
require 'gir_ffi/enum_base'

module GirFFI
  module Builders
    # Implements the creation of an enum or flags type. The type will be
    # attached to the appropriate namespace module, and will be defined
    # as an enum for FFI.
    class EnumBuilder < RegisteredTypeBuilder
      private

      def enum_sym
        @classname.to_sym
      end

      def value_spec
        info.values.map do |vinfo|
          val = GirFFI::ArgHelper.cast_uint32_to_int32(vinfo.value)
          [vinfo.name.to_sym, val]
        end.flatten
      end

      def setup_class
        setup_ffi_type
        klass.extend superclass
        setup_constants
        stub_methods
        setup_inspect
      end

      def klass
        @klass ||= get_or_define_module namespace_module, @classname
      end

      def setup_ffi_type
        optionally_define_constant klass, :Enum do
          lib.enum(enum_sym, value_spec)
        end
      end

      def setup_inspect
        klass.instance_eval <<-EOS
          def self.inspect
            "#{@namespace}::#{@classname}"
          end
        EOS
      end

      def already_set_up
        klass.respond_to? :gtype
      end

      def superclass
        EnumBase
      end
    end
  end
end
