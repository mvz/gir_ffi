require 'gir_ffi/method_stubber'

module GirFFI
  module Builders
    # Implements method creation for types such as, :union, :struct,
    # :object, :interface.
    module WithMethods
      def setup_method method
        go = info.find_method method
        attach_and_define_method method, go, meta_class
      end

      def setup_instance_method method
        go = info.find_instance_method method
        attach_and_define_method method, go, build_class
      end

      private

      def meta_class
        klass = build_class
        return (class << klass; self; end)
      end

      def function_definition go
        FunctionBuilder.new(go).generate
      end

      def attach_and_define_method method, go, modul
        return false if go.nil?
        Builder.attach_ffi_function lib, go
        modul.class_eval { remove_method method }
        build_class.class_eval function_definition(go)
        true
      end

      def stub_methods
        info.get_methods.each do |minfo|
          klass.class_eval MethodStubber.new(minfo).method_stub
        end
      end
    end
  end
end
