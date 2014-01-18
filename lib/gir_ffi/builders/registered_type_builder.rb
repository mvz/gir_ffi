require 'gir_ffi/builders/base_type_builder'
require 'gir_ffi/class_base'

module GirFFI
  module Builders
    # Base class for type builders building types specified by subtypes
    # of IRegisteredTypeInfo. These are types whose C representation is
    # complex, i.e., a struct or a union.
    class RegisteredTypeBuilder < BaseTypeBuilder
      private

      def target_gtype
        info.g_type
      end

      def setup_constants
        klass.const_set :G_TYPE, target_gtype
        super
      end

      # FIXME: Only used in some of the subclases. Make mixin?
      def provide_constructor
        return if info.find_method 'new'

        (class << klass; self; end).class_eval {
          alias_method :new, :_allocate
        }
      end

      def parent
        nil
      end

      def fields
        info.fields
      end

      def superclass
        ClassBase
      end
    end
  end
end
