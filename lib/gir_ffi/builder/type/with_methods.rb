require 'gir_ffi/method_stubber'

module GirFFI
  module Builder
    module Type

      # Implements method creation for types such as, :union, :struct,
      # :object, :interface.
      module WithMethods
        def setup_method method
          go = method_introspection_data method
          attach_and_define_method method, go, meta_class
        end

        def setup_instance_method method
          go = instance_method_introspection_data method
          attach_and_define_method method, go, build_class
        end

        private

        def meta_class
          klass = build_class
          return (class << klass; self; end)
        end

        def method_introspection_data method
          info.find_method method
        end

        def instance_method_introspection_data method
          data = method_introspection_data method
          return data if data && data.method?
        end

        def function_definition_builder go
          Builder::Function.new(go, lib)
        end

        def function_definition go
          function_definition_builder(go).generate
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
            @klass.class_eval MethodStubber.new(minfo).method_stub
          end
        end

        def pretty_print_methods
          info.get_methods.map do |minfo|
            function_definition_builder(minfo).pretty_print.indent + "\n"
          end.join
        end
      end
    end
  end
end
