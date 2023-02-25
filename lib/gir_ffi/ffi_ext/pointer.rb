# frozen_string_literal: true

module GirFFI
  module FFIExt
    # Extensions to FFI::Pointer
    module Pointer
      def self.prepended(base)
        base.class_eval do
          size_t_getter =
            case (size = FFI.type_size(:size_t))
            when 4
              :get_uint32
            when 8
              :get_uint64
            else
              raise NotImplementedError,
                    "Don't know how to handle size_t types of size #{size}"
            end

          alias_method :get_size_t, size_t_getter

          alias_method :get_gtype, :get_size_t
        end
      end

      def to_ptr
        self
      end

      # FIXME: Should probably not be here.
      def to_object
        return nil if null?

        gtype = GObject.type_from_instance_pointer self
        Builder.build_by_gtype(gtype).direct_wrap self
      end

      def to_utf8
        null? ? nil : read_string.force_encoding("utf-8")
      end
    end
  end
end

# @api private
class FFI::Pointer # rubocop:disable Style/ClassAndModuleChildren
  prepend GirFFI::FFIExt::Pointer
end
