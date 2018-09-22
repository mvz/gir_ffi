# frozen_string_literal: true

require 'ffi-gobject_introspection/i_base_info'
module GObjectIntrospection
  # Wraps a GIArgInfo struct.
  # Represents an argument.
  class IArgInfo < IBaseInfo
    def direction
      Lib.g_arg_info_get_direction self
    end

    def return_value?
      Lib.g_arg_info_is_return_value self
    end

    def optional?
      Lib.g_arg_info_is_optional self
    end

    def caller_allocates?
      Lib.g_arg_info_is_caller_allocates self
    end

    def may_be_null?
      Lib.g_arg_info_may_be_null self
    end

    def skip?
      Lib.g_arg_info_is_skip self
    end

    def ownership_transfer
      Lib.g_arg_info_get_ownership_transfer self
    end

    def scope
      Lib.g_arg_info_get_scope self
    end

    def closure
      Lib.g_arg_info_get_closure self
    end

    def destroy
      Lib.g_arg_info_get_destroy self
    end

    def argument_type
      ITypeInfo.wrap Lib.g_arg_info_get_type(self)
    end
  end
end
