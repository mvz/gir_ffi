module GObject

  module RubyStyle

    # TODO: Generate accessor methods from GIR at class definition time
    def method_missing(method, *args)
      if respond_to?("get_#{method}")
        return send("get_#{method}", *args)
      end
      if method.to_s =~ /(.*)=$/ && respond_to?("set_#{$1}")
        return send("set_#{$1}", *args)
      end
      super
    end

    # TODO: Move to definition of GObject::Object
    def signal_connect(event, &block)
      GObject.signal_connect(self, event, &block)
    end

  end

end
