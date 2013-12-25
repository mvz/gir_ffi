require 'gir_ffi/builders/base_type_builder'
require 'gir_ffi/builders/mapping_method_builder'
require 'gir_ffi/receiver_type_info'
require 'gir_ffi/receiver_argument_info'
require 'gir_ffi/signal_base'
require 'gir_ffi/user_data_type_info'
require 'gir_ffi/user_data_argument_info'

module GirFFI
  module Builders
    # Implements the creation of a signal module for handling a particular
    # signal. The type will be attached to the appropriate class.
    class SignalBuilder < BaseTypeBuilder
      def instantiate_class
        unless already_set_up
          klass.extend SignalBase
          setup_constants
          klass.class_eval mapping_method_definition
        end
        klass
      end

      def klass
        @klass ||= get_or_define_module container_class, @classname
      end

      def mapping_method_definition
        arg_infos = info.args

        container_type_info = ReceiverTypeInfo.new(container_info)
        receiver_info = ReceiverArgumentInfo.new(container_type_info)

        user_data_type_info = UserDataTypeInfo.new
        user_data_argument_info = UserDataArgumentInfo.new(user_data_type_info)

        MappingMethodBuilder.for_signal(receiver_info,
                                        arg_infos,
                                        user_data_argument_info,
                                        info.return_type).method_definition
      end

      def container_class
        @container_class ||= Builder.build_class(container_info)
      end

      def container_info
        @container_info ||= info.container
      end
    end
  end
end
