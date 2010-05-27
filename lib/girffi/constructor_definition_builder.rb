module GirFFI
  class ConstructorDefinitionBuilder < Builder::FunctionDefinition
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

