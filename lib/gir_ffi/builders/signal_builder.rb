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

      class SignalReceiverArgumentInfo
        attr_reader :argument_type

        def initialize type
          @argument_type = type
        end

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

      class UserDataArgumentInfo
        attr_reader :argument_type
        attr_reader :closure
        def initialize type, position
          @argument_type = type
          @closure = position
        end
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
    end
  end
end
