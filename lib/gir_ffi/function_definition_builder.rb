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
      @data = @info.args.map {|arg| ArgumentBuilder.build self, arg, @libmodule}
      @data.each {|data| data.prepare }
      @data.each {|data|
	idx = data.arginfo.type.array_length
        data.length_arg = @data[idx] if idx
      }
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
          if is_subclass_of_initially_unowned interface
            @rvdata.post << "GirFFI::GObject.object_ref_sink(#{retval})"
          end
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

    def is_subclass_of_initially_unowned interface
      if interface.namespace == "GObject" and interface.name == "InitiallyUnowned"
        true
      elsif interface.parent
        is_subclass_of_initially_unowned interface.parent
      else
        false
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
