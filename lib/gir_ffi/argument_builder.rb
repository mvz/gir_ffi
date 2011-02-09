module GirFFI
  # Abstract parent class of the argument building classes. These classes
  # are used by FunctionDefinitionBuilder to create the code that processes
  # each argument before and after the actual function call.
  class ArgumentBuilder
    KEYWORDS =  [
      "alias", "and", "begin", "break", "case", "class", "def", "do",
      "else", "elsif", "end", "ensure", "false", "for", "if", "in",
      "module", "next", "nil", "not", "or", "redo", "rescue", "retry",
      "return", "self", "super", "then", "true", "undef", "unless",
      "until", "when", "while", "yield"
    ]

    attr_accessor :arginfo, :inarg, :callarg, :retval, :pre, :post,
      :postpost, :name, :retname, :length_arg

    def initialize function_builder, arginfo=nil
      @arginfo = arginfo
      @inarg = nil
      @callarg = nil
      @retval = nil
      @retname = nil
      @name = nil
      @pre = []
      @post = []
      @postpost = []
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

  # Implements argument processing for arguments with direction :in
  class InArgumentBuilder < ArgumentBuilder
    def prepare
      @name = safe(@arginfo.name)
      @callarg = @function_builder.new_var
      @inarg = @name
    end

    def process
      case @arginfo.type.tag
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
    end

    def process_void_in_arg
      @pre << "#{@callarg} = GirFFI::ArgHelper.object_to_inptr #{@inarg}"
    end

    def process_utf8_in_arg
      @pre << "#{@callarg} = GirFFI::ArgHelper.utf8_to_inptr #{@name}"
      # TODO:
      #@post << "GirFFI::ArgHelper.cleanup_ptr #{@callarg}"
    end

    def process_other_in_arg
      @pre << "#{@callarg} = #{@name}"
    end
  end

  # Implements argument processing for arguments with direction :out
  class OutArgumentBuilder < ArgumentBuilder
    def prepare
      @name = safe(@arginfo.name)
      @callarg = @function_builder.new_var
      @retname = @retval = @function_builder.new_var
    end

    def process
      case @arginfo.type.tag
      when :interface
	process_interface_out_arg
      when :array
	@function_builder.process_array_out_arg self
      else
	process_other_out_arg
      end
    end

    def process_interface_out_arg
      iface = @arginfo.type.interface
      klass = "#{iface.namespace}::#{iface.name}"

      if @arginfo.caller_allocates?
	@pre << "#{@callarg} = #{klass}.allocate"
	@post << "#{@retval} = #{@callarg}"
      else
	@pre << "#{@callarg} = GirFFI::ArgHelper.pointer_outptr"
	@post << "#{@retval} = #{klass}.wrap GirFFI::ArgHelper.outptr_to_pointer(#{@callarg})"
      end
    end

    def process_other_out_arg
      tag = @arginfo.type.tag
      @pre << "#{@callarg} = GirFFI::ArgHelper.#{tag}_outptr"
      @post << "#{@retname} = GirFFI::ArgHelper.outptr_to_#{tag} #{@callarg}"
      if @arginfo.ownership_transfer == :everything
	@post << "GirFFI::ArgHelper.cleanup_ptr #{@callarg}"
      end
    end

  end

  # Implements argument processing for arguments with direction :inout
  class InOutArgumentBuilder < ArgumentBuilder
    def prepare
      @name = safe(@arginfo.name)
      @callarg = @function_builder.new_var
      @inarg = @name
      @retname = @retval = @function_builder.new_var
    end

    def process
      raise NotImplementedError unless @arginfo.ownership_transfer == :everything

      case @arginfo.type.tag
      when :interface
	process_interface_inout_arg
      when :array
	@function_builder.process_array_inout_arg self
      else
	process_other_inout_arg
      end
    end

    def process_interface_inout_arg
      raise NotImplementedError
    end

    def process_other_inout_arg
      tag = @arginfo.type.tag
      @pre << "#{@callarg} = GirFFI::ArgHelper.#{tag}_to_inoutptr #{@inarg}"
      @post << "#{@retval} = GirFFI::ArgHelper.outptr_to_#{tag} #{@callarg}"
      @post << "GirFFI::ArgHelper.cleanup_ptr #{@callarg}"
    end

  end
end
