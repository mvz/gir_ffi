# frozen_string_literal: true

require "ffi"
require "ffi/bit_masks"

require "ffi-gobject_introspection"

require "gir_ffi-base"

require "gir_ffi/ffi_ext"
require "gir_ffi/class_base"
require "gir_ffi/type_map"
require "gir_ffi/info_ext"
require "gir_ffi/in_pointer"
require "gir_ffi/sized_array"
require "gir_ffi/zero_terminated"
require "gir_ffi/arg_helper"
require "gir_ffi/builder"
require "gir_ffi/user_defined_object_info"
require "gir_ffi/builders/user_defined_builder"
require "gir_ffi/version"

module GirFFI
  # Core GirFFI interface.
  module Core
    def setup(namespace, version = nil)
      namespace = namespace.to_s
      Builder.build_module namespace, version
    end

    def define_type(klass)
      unless klass < GirFFI::ObjectBase
        raise ArgumentError, "#{klass} is not a GObject class"
      end

      klass.prepare_user_defined_class
      info = klass.gir_info

      unless info.is_a? UserDefinedObjectInfo
        raise ArgumentError, "#{klass} is not a user-defined class"
      end

      if block_given?
        warn "Using define_type with a block is deprecated." \
             " Call the relevant functions inside the class definition instead."
        yield info
      end
      Builders::UserDefinedBuilder.new(info).build_class

      klass.gtype
    end
  end
end

GirFFI.extend GirFFI::Core
