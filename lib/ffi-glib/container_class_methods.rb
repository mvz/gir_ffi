# frozen_string_literal: true

module GLib
  # Common methods for container classes: Array, PtrArray, List, SList and
  # HashTable.
  module ContainerClassMethods
    def wrap(typespec, ptr)
      # HACK: wrap and from are almost the same!
      ptr = case ptr
            when nil
              nil
            when FFI::Pointer
              ptr
            when self, GirFFI::BoxedBase
              ptr.to_ptr
            end

      super(ptr).tap do |container|
        container&.reset_typespec typespec
      end
    end

    def from(typespec = :void, obj)
      case obj
      when nil
        nil
      when FFI::Pointer
        wrap typespec, obj
      when self
        obj.reset_typespec typespec
      when GirFFI::BoxedBase
        wrap typespec, obj.to_ptr
      else
        from_enumerable typespec, obj
      end
    end
  end
end
