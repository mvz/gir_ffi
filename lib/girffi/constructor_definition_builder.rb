module GirFFI
  # Implements the creation of a Ruby constructor definition out of a GIR
  # IFunctionInfo, if it represents a constructor.
  class ConstructorDefinitionBuilder < FunctionDefinitionBuilder
    private
    def filled_out_template
      return <<-CODE
	def #{@info.name} #{@inargs.join(', ')}
	  #{@pre.join("\n")}
	  _real_new #{@libmodule}.#{@info.symbol}(#{@callargs.join(', ')})
	  #{@post.join("\n")}
	end
      CODE
    end
  end
end

