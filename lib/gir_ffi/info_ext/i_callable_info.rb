# frozen_string_literal: true

module GirFFI
  module InfoExt
    # Extensions for GObjectIntrospection::ICallableInfo needed by GirFFI
    module ICallableInfo
      def argument_ffi_types
        args.map(&:to_ffi_type)
      end
    end
  end
end

GObjectIntrospection::ICallableInfo.send :include, GirFFI::InfoExt::ICallableInfo
