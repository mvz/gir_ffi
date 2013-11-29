require 'gir_ffi/return_value_info'
require 'gir_ffi/builders/base_type_builder'
require 'gir_ffi/builders/mapping_method_builder'
require 'gir_ffi/receiver_type_info'

module GirFFI
  module Builders
    class VFuncBuilder < BaseTypeBuilder
      def mapping_method_definition
        arg_infos = info.args

        container_type_info = ReceiverTypeInfo.new(container_info)
        receiver_info = ReturnValueInfo.new(container_type_info)

        MappingMethodBuilder.for_vfunc(receiver_info,
                                       arg_infos,
                                       info.return_type).method_definition
      end

      def container_info
        @container_info ||= info.container
      end
    end
  end
end
