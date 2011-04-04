require 'gir_ffi/builder/type/registered_type'
module GirFFI
  module Builder
    module Type

      # Implements the creation of a class representing one of the types
      # whose C representation is a struct, i.e., :object, :struct, and
      # :interface.
      class StructBased < RegisteredType
        def build_class
          unless defined? @klass
            instantiate_struct_class
          end
          @klass
        end

        def instantiate_struct_class
          @klass = get_or_define_class namespace_module, @classname, superclass
          @structklass = get_or_define_class @klass, :Struct, FFI::Struct
          setup_class unless already_set_up
        end

        def find_signal signal_name
          signal_definers.each do |inf|
            inf.signals.each do |sig|
              return sig if sig.name == signal_name
            end
          end
          if parent
            return superclass.gir_ffi_builder.find_signal signal_name
          end
        end

        def signal_definers
          [info]
        end
      end
    end
  end
end
