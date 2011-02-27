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

      @rvdata = ReturnValueBuilder.new self, @info
      @rvdata.prepare

      @data.each {|data|
	idx = data.arginfo.type.array_length
        data.length_arg = @data[idx] if idx > -1
      }

      idx = @rvdata.arginfo.return_type.array_length
      @rvdata.length_arg = @data[idx] if idx > -1

      @data.each {|data| data.process }

      @rvdata.process

      if @rvdata.cvar
        @capture = "#{@rvdata.cvar} = "
      end

      adjust_accumulators
      return filled_out_template
    end

    def setup_accumulators
      @data = []

      @capture = ""

      @varno = 0
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
