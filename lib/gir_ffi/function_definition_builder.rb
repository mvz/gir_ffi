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
      klass = @info.throws? ? ErrorHandlerBuilder : NullArgumentBuilder
      @errarg = klass.new(self)
      @errarg.prepare
      @errarg.process
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
      ca = @data.map(&:callarg)
      ca << @errarg.callarg
      ca.unshift "self" if @info.method?
      ca.compact
    end

    def pre
      pr = @data.map(&:pre)
      pr << @errarg.pre
      pr.flatten
    end

    def capture
      if (cv = @rvdata.cvar)
        "#{cv} = "
      else
        ""
      end
    end

    def post
      po = (@data.map(&:post) + @data.map(&:postpost) + @rvdata.post)
      po.unshift @errarg.post

      retvals = ([@rvdata.retval] + @data.map(&:retval)).compact
      po << "return #{retvals.join(', ')}" unless retvals.empty?

      po.flatten
    end

    def new_var
      @varno += 1
      "_v#{@varno}"
    end

    public :new_var
  end
end
