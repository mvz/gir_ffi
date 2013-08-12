module GLib
  module ContainerClassMethods
    def wrap typespec, ptr
      super(ptr).tap do |container|
        container.reset_typespec typespec if container
      end
    end

    def from typespec, it
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
