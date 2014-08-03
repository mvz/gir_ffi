require 'gir_ffi/builders/base_type_builder'
require 'gir_ffi/method_stubber'
require 'gir_ffi/class_base'

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

      def function_definition go
        FunctionBuilder.new(go).generate
      end

      def attach_and_define_method method, go, modul
        return unless go
        method = go.safe_name
        Builder.attach_ffi_function lib, go
        modul.class_eval { remove_method method if method_defined? method }
        build_class.class_eval function_definition(go)
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

      # FIXME: Only used in some of the subclases. Make mixin?
      def provide_constructor
        return if info.find_method 'new'

        (class << klass; self; end).class_eval {
          alias_method :new, :_allocate
        }
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
