module GLib
  # Common methods for container classes: Array, PtrArray, List, SList and
  # HashTable.
  module ContainerClassMethods
    def wrap typespec, ptr
      super(ptr).tap do |container|
        container.reset_typespec typespec if container
      end
    end

    # FIXME: Drop Ruby 1.8.7 support and make first argument optional.
    def from *args
      it, typespec = *args.reverse
      typespec ||= :void
      case it
      when nil
        nil
      when FFI::Pointer
        wrap typespec, it
      when self
        it.reset_typespec typespec
      else
        from_enumerable typespec, it
      end
    end
  end
end
