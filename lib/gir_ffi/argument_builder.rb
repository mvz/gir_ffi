module GirFFI
  class ArgumentBuilder
    attr_accessor :arginfo, :inarg, :callarg, :retval, :pre, :post,
      :postpost, :name, :retname

    def initialize function_builder, arginfo=nil
      self.arginfo = arginfo
      self.inarg = nil
      self.callarg = nil
      self.retval = nil
      self.retname = nil
      self.name = nil
      self.pre = []
      self.post = []
      self.postpost = []
      @function_builder = function_builder
    end

    def self.build function_builder, arginfo
      klass = case arginfo.direction
              when :inout
                InOutArgumentBuilder
              when :in
                InArgumentBuilder
              when :out
                OutArgumentBuilder
              else
                raise ArgumentError
              end
      klass.new function_builder, arginfo
    end
  end

  class InArgumentBuilder < ArgumentBuilder
    def process
      @function_builder.process_in_arg self
    end
  end

  class OutArgumentBuilder < ArgumentBuilder
    def process
      @function_builder.process_out_arg self
    end
  end

  class InOutArgumentBuilder < ArgumentBuilder
    def process
      @function_builder.process_inout_arg self
    end
  end
end
