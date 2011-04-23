require 'gir_ffi/builder/type/base'
module GirFFI
  module Builder
    module Type

      # Implements the creation of a constant. Though semantically not a
      # type, its build method is like that of the types, in that it is
      # triggered by a missing constant in the parent namespace.  The
      # constant will be attached to the appropriate namespace module.
      class Constant < Base
        TYPE_TAG_TO_UNION_MEMBER = {
          :gint32 => :v_int32,
          :gdouble => :v_double,
          :utf8 => :v_string
        }

        def build_class
          unless defined? @klass
            instantiate_class
          end
          @klass
        end

        def instantiate_class
          @klass = optionally_define_constant namespace_module, @classname do
            info.value[TYPE_TAG_TO_UNION_MEMBER[info.constant_type.tag]]
          end
        end
      end
    end
  end
end

