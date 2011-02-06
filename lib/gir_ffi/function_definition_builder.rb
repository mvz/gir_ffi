require 'gir_ffi/argument_builder'

module GirFFI
  # Implements the creation of a Ruby function definition out of a GIR
  # IFunctionInfo.
  class FunctionDefinitionBuilder
    def initialize info, libmodule
      @info = info
      @libmodule = libmodule
    end

    def generate
      setup_accumulators
      @data = @info.args.map {|a| ArgumentBuilder.build self, a}
      @data.each {|data| data.prepare }
      @data.each {|data| data.process }
      process_return_value
      adjust_accumulators
      return filled_out_template
    end

    def setup_accumulators
      @data = []

      @capture = ""

      @varno = 0
    end

    def process_inout_arg data
      arg = data.arginfo

      raise NotImplementedError unless arg.ownership_transfer == :everything

      case arg.type.tag
      when :interface
	process_interface_inout_arg data
      when :array
	process_array_inout_arg data
      else
	process_other_inout_arg data
      end

      data
    end

    def process_interface_inout_arg data
      raise NotImplementedError
    end

    def process_array_inout_arg data
      arg = data.arginfo
      tag = arg.type.param_type(0).tag
      data.pre << "#{data.callarg} = GirFFI::ArgHelper.#{tag}_array_to_inoutptr #{data.inarg}"
      if arg.type.array_length > -1
	idx = arg.type.array_length
	lendata = @data[idx]
	rv = lendata.retval
	lendata.retval = nil
	lname = lendata.inarg
	lendata.inarg = nil
	lendata.pre.unshift "#{lname} = #{data.inarg}.length"
	data.post << "#{data.retval} = GirFFI::ArgHelper.outptr_to_#{tag}_array #{data.callarg}, #{rv}"
	if tag == :utf8
	  data.post << "GirFFI::ArgHelper.cleanup_ptr_array_ptr #{data.callarg}, #{rv}"
	else
	  data.post << "GirFFI::ArgHelper.cleanup_ptr_ptr #{data.callarg}"
	end
      else
	raise NotImplementedError
      end
    end

    def process_other_inout_arg data
      tag = data.arginfo.type.tag
      data.pre << "#{data.callarg} = GirFFI::ArgHelper.#{tag}_to_inoutptr #{data.inarg}"
      data.post << "#{data.retval} = GirFFI::ArgHelper.outptr_to_#{tag} #{data.callarg}"
      data.post << "GirFFI::ArgHelper.cleanup_ptr #{data.callarg}"
    end

    def process_out_arg data
      arg = data.arginfo

      case arg.type.tag
      when :interface
	process_interface_out_arg data
      when :array
	process_array_out_arg data
      else
	process_other_out_arg data
      end

      data
    end

    def process_interface_out_arg data
      arg = data.arginfo
      iface = arg.type.interface

      if arg.caller_allocates?
	data.pre << "#{data.callarg} = #{iface.namespace}::#{iface.name}.allocate"
	data.post << "#{data.retval} = #{data.callarg}"
      else
	data.pre << "#{data.callarg} = GirFFI::ArgHelper.pointer_outptr"
	tmpvar = new_var
	data.post << "#{tmpvar} = GirFFI::ArgHelper.outptr_to_pointer #{data.callarg}"
	data.post << "#{data.retval} = #{iface.namespace}::#{iface.name}.wrap #{tmpvar}"
      end
    end

    def process_array_out_arg data
      data.pre << "#{data.callarg} = GirFFI::ArgHelper.pointer_outptr"

      arg = data.arginfo
      type = arg.type
      tag = type.param_type(0).tag
      size = type.array_fixed_size
      idx = type.array_length

      if size <= 0
	if idx > -1
	  size = @data[idx].retval
	  @data[idx].retval = nil
	else
	  raise NotImplementedError
	end
      end

      data.postpost << "#{data.retval} = GirFFI::ArgHelper.outptr_to_#{tag}_array #{data.callarg}, #{size}"

      if arg.ownership_transfer == :everything
	if tag == :utf8
	  data.postpost << "GirFFI::ArgHelper.cleanup_ptr_array_ptr #{data.callarg}, #{rv}"
	else
	  data.postpost << "GirFFI::ArgHelper.cleanup_ptr_ptr #{data.callarg}"
	end
      end
    end

    def process_other_out_arg data
      arg = data.arginfo
      tag = arg.type.tag
      data.pre << "#{data.callarg} = GirFFI::ArgHelper.#{tag}_outptr"
      data.post << "#{data.retname} = GirFFI::ArgHelper.outptr_to_#{tag} #{data.callarg}"
      if arg.ownership_transfer == :everything
	data.post << "GirFFI::ArgHelper.cleanup_ptr #{data.callarg}"
      end
    end

    def process_in_arg data
      arg = data.arginfo

      case arg.type.tag
      when :interface
	process_interface_in_arg data
      when :void
	process_void_in_arg data
      when :array
	process_array_in_arg data
      when :utf8
	process_utf8_in_arg data
      else
	process_other_in_arg data
      end

      data
    end

    def process_interface_in_arg data
      arg = data.arginfo
      type = arg.type

      iface = type.interface
      if iface.type == :callback
	data.pre << "#{data.callarg} = GirFFI::ArgHelper.wrap_in_callback_args_mapper \"#{iface.namespace}\", \"#{iface.name}\", #{data.inarg}"
	data.pre << "::#{@libmodule}::CALLBACKS << #{data.callarg}"
      else
	data.pre << "#{data.callarg} = #{data.inarg}"
      end
    end

    def process_void_in_arg data
      data.pre << "#{data.callarg} = GirFFI::ArgHelper.object_to_inptr #{data.inarg}"
    end

    def process_array_in_arg data
      arg = data.arginfo
      type = arg.type

      if type.array_fixed_size > 0
	data.pre << "GirFFI::ArgHelper.check_fixed_array_size #{type.array_fixed_size}, #{data.inarg}, \"#{data.inarg}\""
      elsif type.array_length > -1
	idx = type.array_length
	lenvar = @data[idx].inarg
	@data[idx].inarg = nil
	@data[idx].pre.unshift "#{lenvar} = #{data.inarg}.nil? ? 0 : #{data.inarg}.length"
      end

      tag = arg.type.param_type(0).tag.to_s.downcase
      data.pre << "#{data.callarg} = GirFFI::ArgHelper.#{tag}_array_to_inptr #{data.inarg}"
      unless arg.ownership_transfer == :everything
	if tag == :utf8
	  data.post << "GirFFI::ArgHelper.cleanup_ptr_ptr #{data.callarg}"
	else
	  data.post << "GirFFI::ArgHelper.cleanup_ptr #{data.callarg}"
	end
      end
    end

    def process_utf8_in_arg data
      data.pre << "#{data.callarg} = GirFFI::ArgHelper.utf8_to_inptr #{data.name}"
      # TODO:
      #data.post << "GirFFI::ArgHelper.cleanup_ptr #{data.callarg}"
    end

    def process_other_in_arg data
      data.pre << "#{data.callarg} = #{data.name}"
    end

    def process_return_value
      @rvdata = ArgumentBuilder.new self
      type = @info.return_type
      tag = type.tag

      return if tag == :void

      cvar = new_var
      @capture = "#{cvar} = "

      case tag
      when :interface
	process_interface_return_value type, cvar
      when :array
	process_array_return_value type, cvar
      else
	process_other_return_value cvar
      end
    end

    def process_interface_return_value type, cvar
      interface = type.interface
      namespace = interface.namespace
      name = interface.name
      retval = new_var

      case interface.type
      when :interface
	GirFFI::Builder.build_class namespace, name
	@rvdata.post << "#{retval} = ::#{namespace}::#{name}.wrap(#{cvar})"
      when :object
	if @info.constructor?
	  GirFFI::Builder.build_class namespace, name
	  @rvdata.post << "#{retval} = ::#{namespace}::#{name}.wrap(#{cvar})"
	  @rvdata.post << "GirFFI::ArgHelper.sink_if_floating(#{retval})"
	else
	  @rvdata.post << "#{retval} = GirFFI::ArgHelper.object_pointer_to_object(#{cvar})"
	end
      when :struct
	GirFFI::Builder.build_class namespace, name
	@rvdata.post << "#{retval} = ::#{namespace}::#{name}.wrap(#{cvar})"
      else
	@rvdata.post << "#{retval} = #{cvar}"
      end

      @rvdata.retval = retval
    end

    def process_array_return_value type, cvar
      tag = type.param_type(0).tag
      size = type.array_fixed_size
      idx = type.array_length

      retval = new_var
      if size > 0
	@rvdata.post << "#{retval} = GirFFI::ArgHelper.ptr_to_#{tag}_array #{cvar}, #{size}"
      elsif idx > -1
	lendata = @data[idx]
	rv = lendata.retval
	lendata.retval = nil
	@rvdata.post << "#{retval} = GirFFI::ArgHelper.ptr_to_#{tag}_array #{cvar}, #{rv}"
      end
      @rvdata.retval = retval
    end

    def process_other_return_value cvar
      @rvdata.retval = cvar
    end

    def adjust_accumulators
      @retvals = ([@rvdata.retval] + @data.map(&:retval)).compact
      @callargs = @data.map(&:callarg).compact
      @inargs = @data.map(&:inarg).compact
      @pre = @data.map(&:pre).flatten
      @post = (@data.map(&:post) + @data.map(&:postpost) + @rvdata.post).flatten

      if @info.throws?
	errvar = new_var
	@pre << "#{errvar} = FFI::MemoryPointer.new(:pointer).write_pointer nil"
	@post.unshift "GirFFI::ArgHelper.check_error(#{errvar})"
	@callargs << errvar
      end

      @post << "return #{@retvals.join(', ')}" unless @retvals.empty?

      if @info.method?
	@callargs.unshift "self"
      end
    end

    def filled_out_template
      return <<-CODE
	def #{@info.name} #{@inargs.join(', ')}
	  #{@pre.join("\n")}
	  #{@capture}::#{@libmodule}.#{@info.symbol} #{@callargs.join(', ')}
	  #{@post.join("\n")}
	end
      CODE
    end

    def new_var
      @varno += 1
      "_v#{@varno}"
    end
  end
end
