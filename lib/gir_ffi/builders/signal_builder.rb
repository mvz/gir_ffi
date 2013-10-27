require 'gir_ffi/return_value_info'
require 'gir_ffi/builders/base_type_builder'
require 'gir_ffi/builders/mapping_method_builder'
require 'gir_ffi/signal_base'

module GirFFI
  module Builders
    # Implements the creation of a signal module for handling a particular
    # signal. The type will be attached to the appropriate class.
    class SignalBuilder < BaseTypeBuilder
      class SignalReceiverTypeInfo
        include InfoExt::ITypeInfo

        def initialize interface_info
          @interface_info = interface_info
        end

        def interface
          @interface_info
        end

        def tag
          :interface
        end
      end

      class SignalReceiverArgumentInfo < ReturnValueInfo
        def closure
          -1
        end
      end

      class UserDataTypeInfo
        include InfoExt::ITypeInfo

        def tag
          :void
        end

        def pointer?
          true
        end
      end

      class UserDataArgumentInfo < ReturnValueInfo
        attr_reader :closure

        def initialize type, position
          super type
          @closure = position
        end
      end

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

        container_type_info = SignalReceiverTypeInfo.new(container_info)
        arg_infos.unshift SignalReceiverArgumentInfo.new(container_type_info)

        user_data_type_info = UserDataTypeInfo.new
        user_data_argument_info = UserDataArgumentInfo.new(user_data_type_info, arg_infos.length)
        arg_infos.push user_data_argument_info

        MappingMethodBuilder.new(arg_infos, info.return_type).method_definition
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
