require 'gir_ffi/builder/type/base'
require 'gir_ffi/class_base'

module GirFFI
  module Builder
    module Type

      # Base class for type builders building types specified by subtypes
      # of IRegisteredTypeInfo. These are types whose C representation is
      # complex, i.e., a struct or a union.
      class RegisteredType < Base
        private

        def target_gtype
          info.g_type
        end

        # TODO: Rename the created method, or use a constant.
        # FIXME: Only used in some of the subclases. Make mixin?
        def setup_gtype_getter
          gtype = target_gtype
          return if gtype.nil?
          @klass.instance_eval "
            def self.get_gtype
              #{gtype}
            end
          "
        end

        # FIXME: Only used in some of the subclases. Make mixin?
        def provide_constructor
          return if info.find_method 'new'

          (class << @klass; self; end).class_eval {
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
end
