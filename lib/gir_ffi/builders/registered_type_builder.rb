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
      def setup_method method
        go = info.find_method method
        attach_and_define_method method, go, meta_class
      end

      def setup_instance_method method
        go = info.find_instance_method method
        attach_and_define_method method, go, build_class
      end

      def target_gtype
        info.g_type
      end

      private

      def meta_class
        (class << build_class; self; end)
      end

      def attach_and_define_method method, go, modul
        return unless go
        method = go.safe_name
        Builder.attach_ffi_function lib, go
        modul.class_eval { remove_method method if method_defined? method }
        if go.constructor?
          build_class.class_eval InitializerBuilder.new(go).generate
          build_class.class_eval ConstructorBuilder.new(go).generate
        else
          build_class.class_eval FunctionBuilder.new(go).generate
        end
        method
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
