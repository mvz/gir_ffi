# frozen_string_literal: true
module GirFFI
  # Represents the type of the receiver of a signal or vfunc, conforming, as
  # needed, to the interface of GObjectIntrospection::ITypeInfo
  class ReceiverTypeInfo
    include InfoExt::ITypeInfo

    def initialize(interface_info)
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

    def array_length
      -1
    end
  end
end
