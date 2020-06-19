# frozen_string_literal: true

require "gir_ffi/builders/struct_builder"

module GirFFI
  module Builders
    # Implements the creation of a class representing a Struct.
    class ClassStructBuilder < RegisteredTypeBuilder
      include StructLike

      attr_reader :superclass

      def initialize(info, super_class_struct)
        @superclass = super_class_struct
        super info
        raise "Info does not represent gtype_struct" unless info.gtype_struct?
      end

      def layout_superclass
        GirFFI::Struct
      end
    end
  end
end
