module GirFFI
  class ArgumentBuilder
    KEYWORDS =  [
      "alias", "and", "begin", "break", "case", "class", "def", "do",
      "else", "elsif", "end", "ensure", "false", "for", "if", "in",
      "module", "next", "nil", "not", "or", "redo", "rescue", "retry",
      "return", "self", "super", "then", "true", "undef", "unless",
      "until", "when", "while", "yield"
    ]

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

    def safe name
      if KEYWORDS.include? name
	"#{name}_"
      else
	name
      end
    end
  end

  class InArgumentBuilder < ArgumentBuilder
    def prepare
      @name = safe(arginfo.name)
      @callarg = @function_builder.new_var
      @inarg = @name
    end

    def process
      @function_builder.process_in_arg self
    end
  end

  class OutArgumentBuilder < ArgumentBuilder
    def prepare
      @name = safe(arginfo.name)
      @callarg = @function_builder.new_var
      @retname = @retval = @function_builder.new_var
    end

    def process
      @function_builder.process_out_arg self
    end
  end

  class InOutArgumentBuilder < ArgumentBuilder
    def prepare
      @name = safe(arginfo.name)
      @callarg = @function_builder.new_var
      @inarg = @name
      @retname = @retval = @function_builder.new_var
    end

    def process
      @function_builder.process_inout_arg self
    end
  end
end
