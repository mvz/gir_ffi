module GirFFI
  class ConstructorDefinitionBuilder < Builder::FunctionDefinition
    private
    def filled_out_template
      return <<-CODE
	def initialize #{@inargs.join(', ')}
	  #{@pre.join("\n")}
	  @gobj = #{@libmodule}.#{@info.symbol} #{@callargs.join(', ')}
	  #{@post.join("\n")}
	end
      CODE
    end
  end
end

