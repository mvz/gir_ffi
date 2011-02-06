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
      process_in_arg
    end

    def process_in_arg
      arg = self.arginfo

      case arg.type.tag
      when :interface
	@function_builder.process_interface_in_arg self
      when :void
	process_void_in_arg
      when :array
	@function_builder.process_array_in_arg self
      when :utf8
	process_utf8_in_arg
      else
	process_other_in_arg
      end

      self
    end

    def process_void_in_arg
      self.pre << "#{self.callarg} = GirFFI::ArgHelper.object_to_inptr #{self.inarg}"
    end

    def process_utf8_in_arg
      self.pre << "#{self.callarg} = GirFFI::ArgHelper.utf8_to_inptr #{self.name}"
      # TODO:
      #self.post << "GirFFI::ArgHelper.cleanup_ptr #{self.callarg}"
    end

    def process_other_in_arg
      self.pre << "#{self.callarg} = #{self.name}"
    end
  end

  class OutArgumentBuilder < ArgumentBuilder
    def prepare
      @name = safe(arginfo.name)
      @callarg = @function_builder.new_var
      @retname = @retval = @function_builder.new_var
    end

    def process
      arg = self.arginfo

      case arg.type.tag
      when :interface
	process_interface_out_arg
      when :array
	@function_builder.process_array_out_arg self
      else
	process_other_out_arg
      end

      self
    end

    def process_interface_out_arg
      arg = self.arginfo
      iface = arg.type.interface

      if arg.caller_allocates?
	self.pre << "#{self.callarg} = #{iface.namespace}::#{iface.name}.allocate"
	self.post << "#{self.retval} = #{self.callarg}"
      else
	self.pre << "#{self.callarg} = GirFFI::ArgHelper.pointer_outptr"
	tmpvar = @function_builder.new_var
	self.post << "#{tmpvar} = GirFFI::ArgHelper.outptr_to_pointer #{self.callarg}"
	self.post << "#{self.retval} = #{iface.namespace}::#{iface.name}.wrap #{tmpvar}"
      end
    end

    def process_other_out_arg
      arg = self.arginfo
      tag = arg.type.tag
      self.pre << "#{self.callarg} = GirFFI::ArgHelper.#{tag}_outptr"
      self.post << "#{self.retname} = GirFFI::ArgHelper.outptr_to_#{tag} #{self.callarg}"
      if arg.ownership_transfer == :everything
	self.post << "GirFFI::ArgHelper.cleanup_ptr #{self.callarg}"
      end
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
      arg = self.arginfo

      raise NotImplementedError unless arg.ownership_transfer == :everything

      case arg.type.tag
      when :interface
	process_interface_inout_arg
      when :array
	@function_builder.process_array_inout_arg self
      else
	process_other_inout_arg
      end

      self
    end

    def process_interface_inout_arg
      raise NotImplementedError
    end

    def process_other_inout_arg
      tag = self.arginfo.type.tag
      self.pre << "#{self.callarg} = GirFFI::ArgHelper.#{tag}_to_inoutptr #{self.inarg}"
      self.post << "#{self.retval} = GirFFI::ArgHelper.outptr_to_#{tag} #{self.callarg}"
      self.post << "GirFFI::ArgHelper.cleanup_ptr #{self.callarg}"
    end

  end
end
