require 'gir_ffi/builder/argument'
require 'gir_ffi/variable_name_generator'

module GirFFI::Builder
  # Implements the creation of a Ruby function definition out of a GIR
  # IFunctionInfo.
  class Function
    def initialize info, libmodule
      @info = info
      @libmodule = libmodule
    end

    def generate
      vargen = GirFFI::VariableNameGenerator.new
      @data = @info.args.map {|arg| Argument.build vargen, arg}
      @rvdata = ReturnValueFactory.build vargen, @info

      alldata = @data.dup << @rvdata

      alldata.each {|data|
	idx = data.type_info.array_length
        if idx > -1
          data.length_arg = @data[idx] 
          @data[idx].array_arg = data
        end
      }

      setup_error_argument vargen
      return filled_out_template
    end

    def pretty_print
      generate
    end

    private

    def setup_error_argument vargen
      klass = @info.throws? ? ErrorArgument : NullArgument
      @errarg = klass.new vargen, nil, nil, :error
    end

    def filled_out_template
      lines = pre
      lines << "#{capture}#{@libmodule}.#{@info.symbol} #{callargs.join(', ')}"
      lines << post

      meta = @info.method? ? '' : "self."

      code = "def #{meta}#{@info.safe_name} #{inargs.join(', ')}\n"
      code << lines.join("\n").indent
      code << "\nend\n"
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
      args = @data.sort_by {|arg| arg.type_info.array_length}

      po = args.map {|arg|arg.post} +
        @rvdata.post
      po.unshift @errarg.post

      po += @data.map {|item| item.cleanup}

      retvals = ([@rvdata.retval] + @data.map(&:retval)).compact
      po << "return #{retvals.join(', ')}" unless retvals.empty?

      po.flatten
    end
  end
end
