require 'gir_ffi/builders/base_type_builder'
require 'gir_ffi/method_stubber'
require 'gir_ffi/builders/function_builder'
require 'gir_ffi/builders/constructor_builder'
require 'gir_ffi/builders/initializer_builder'

module GirFFI
  module Builders
    # Base class for type builders building types specified by subtypes
    # of IRegisteredTypeInfo. These are types whose C representation is
    # complex, i.e., a struct or a union.
    class RegisteredTypeBuilder < BaseTypeBuilder
      def setup_method(method)
        method_info = info.find_method method
        return unless method_info
        attach_and_define_method method_info, meta_class
      end

      def setup_instance_method(method)
        method_info = info.find_instance_method method
        return unless method_info
        attach_and_define_method method_info, build_class
      end

      def target_gtype
        info.g_type
      end

      private

      def meta_class
        (class << build_class; self; end)
      end

      def attach_and_define_method(method_info, modul)
        method = method_info.safe_name
        attach_method method_info
        remove_old_method method, modul
        define_method method_info
        method
      end

      def define_method(method_info)
        if method_info.constructor?
          build_class.class_eval InitializerBuilder.new(method_info).generate
          build_class.class_eval ConstructorBuilder.new(method_info).generate
        else
          build_class.class_eval FunctionBuilder.new(method_info).generate
        end
      end

      def remove_old_method(method, modul)
        modul.class_eval { remove_method method if method_defined? method }
      end

      def attach_method(method_info)
        Builder.attach_ffi_function lib, method_info
      end

      def stub_methods
        info.get_methods.each do |minfo|
          klass.class_eval MethodStubber.new(minfo).method_stub
        end
      end

      def setup_constants
        klass.const_set :G_TYPE, target_gtype
        super
      end

      def parent_info
        nil
      end

      def fields
        info.fields
      end
    end
  end
end
