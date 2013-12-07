module GirFFI
  class ReceiverTypeInfo
    include InfoExt::ITypeInfo

    def initialize interface_info
      @interface_info = interface_info
    end

    def interface
      @interface_info
    end

    def tag
      :interface
    end

    def pointer?
      false
    end
  end
end
