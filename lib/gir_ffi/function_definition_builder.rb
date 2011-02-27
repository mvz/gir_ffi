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
      @rvdata = ReturnValueBuilder.new self, @info

      alldata = @data.dup << @rvdata

      alldata.each {|data|
        data.prepare
	idx = data.type.array_length
        data.length_arg = @data[idx] if idx > -1
      }

      alldata.each {|data| data.process }

      adjust_accumulators
      return filled_out_template
    end

    private

    def setup_accumulators
      @varno = 0
    end

    def adjust_accumulators
      if @info.throws?
	@errvar = new_var
      end
    end

    def filled_out_template
      return <<-CODE
	def #{@info.name} #{inargs.join(', ')}
	  #{pre.join("\n")}
	  #{capture}::#{@libmodule}.#{@info.symbol} #{callargs.join(', ')}
	  #{post.join("\n")}
	end
      CODE
    end

    def inargs
      @data.map(&:inarg).compact
    end

    def callargs
      ca = @data.map(&:callarg).compact
      ca << @errvar if @info.throws?
      ca.unshift "self" if @info.method?
      ca
    end

    def pre
      pr = @data.map(&:pre).flatten

      if @info.throws?
	pr << "#{@errvar} = FFI::MemoryPointer.new(:pointer).write_pointer nil"
      end
      pr
    end

    def capture
      if (cv = @rvdata.cvar)
        "#{cv} = "
      else
        ""
      end
    end

    def post
      po = (@data.map(&:post) + @data.map(&:postpost) + @rvdata.post).flatten
      po.unshift "GirFFI::ArgHelper.check_error(#{@errvar})" if @info.throws?

      retvals = ([@rvdata.retval] + @data.map(&:retval)).compact
      po << "return #{retvals.join(', ')}" unless retvals.empty?

      po
    end

    def new_var
      @varno += 1
      "_v#{@varno}"
    end

    public :new_var
  end
end
