module GLib
  module ListInstanceMethods
    def each
      list = self
      rval = nil
      until list.nil?
        rval = yield GirFFI::ArgHelper.cast_from_pointer(element_type, list[:data])
        list = self.class.wrap(element_type, list[:next])
      end
      rval
    end
  end
end

