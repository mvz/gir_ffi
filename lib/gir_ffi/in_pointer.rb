module GirFFI
  class InPointer
    def self.from_array type, array
      ArgHelper.typed_array_to_inptr type, array
    end
  end
end
