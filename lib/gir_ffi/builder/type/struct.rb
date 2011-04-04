require 'gir_ffi/builder/type/struct_based'
module GirFFI
  module Builder
    module Type

      # Implements the creation of a class representing a Struct.
      class Struct < StructBased
        def setup_class
          super
          provide_struct_constructor
        end

        def provide_struct_constructor
          return if info.find_method 'new'

          (class << @klass; self; end).class_eval {
            alias_method :new, :allocate
          }
        end
      end
    end
  end
end


