require 'gir_ffi/return_value_info'
require 'gir_ffi/builders/base_type_builder'
require 'gir_ffi/builders/mapping_method_builder'
require 'gir_ffi/receiver_type_info'
require 'gir_ffi/vfunc_base'

module GirFFI
  module Builders
    # Implements the creation of a class representing the implementation of a
    # vfunc. This class will be able to turn a proc into an FFI::Function that
    # can serve as such an implementation in C.
    class VFuncBuilder < BaseTypeBuilder
      def instantiate_class
        unless already_set_up
          setup_constants
          klass.class_eval mapping_method_definition
        end
        klass
      end

      def klass
        @klass ||= get_or_define_class container_class, @classname, CallbackBase
      end

      def mapping_method_definition
        arg_infos = info.args

        receiver_info = ReturnValueInfo.new(receiver_type_info)

        MappingMethodBuilder.for_vfunc(receiver_info,
                                       arg_infos,
                                       info.return_type).method_definition
      end

      def receiver_type_info
        ReceiverTypeInfo.new(container_info)
      end

      def container_class
        @container_class ||= Builder.build_class(container_info)
      end

      def container_info
        @container_info ||= info.container
      end

      def argument_types
        @argument_types ||= info.argument_ffi_types.unshift(receiver_type_info.to_ffitype)
      end

      def return_type
        @return_type ||= info.return_ffi_type
      end
    end
  end
end
