module GLib
  # Common methods for container classes: Array, PtrArray, List, SList and
  # HashTable.
  module ContainerClassMethods
    def wrap(typespec, ptr)
      super(ptr).tap do |container|
        container.reset_typespec typespec if container
      end
    end

    def from(typespec = :void, it)
      case it
      when nil
        nil
      when FFI::Pointer
        wrap typespec, it
      when self
        it.reset_typespec typespec
      when GirFFI::BoxedBase
        wrap typespec, it.to_ptr
      else
        from_enumerable typespec, it
      end
    end
  end
end
