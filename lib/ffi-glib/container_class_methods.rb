module GLib
  module ContainerClassMethods
    def wrap typespec, ptr
      super(ptr).tap do |it|
        break if it.nil?
        it.reset_typespec typespec
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


