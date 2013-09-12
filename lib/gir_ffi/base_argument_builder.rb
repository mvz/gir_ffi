module GirFFI
  # Abstract parent class of the argument building classes. These
  # classes are used by FunctionBuilder to create the code that
  # processes each argument before and after the actual function call.
  class BaseArgumentBuilder
    KEYWORDS = [
      "alias", "and", "begin", "break", "case", "class", "def", "do",
      "else", "elsif", "end", "ensure", "false", "for", "if", "in",
      "module", "next", "nil", "not", "or", "redo", "rescue", "retry",
      "return", "self", "super", "then", "true", "undef", "unless",
      "until", "when", "while", "yield"
    ]

    attr_reader :name, :retname

    attr_accessor :length_arg, :array_arg

    def initialize var_gen, name, typeinfo, direction
      @var_gen = var_gen

      @typeinfo = typeinfo
      @direction = direction
      @name = safe(name)

      @inarg = nil
      @retname = nil

      @length_arg = nil
      @array_arg = nil
    end

    def type_info
      @typeinfo
    end

    def specialized_type_tag
      type_info.flattened_tag
    end

    # TODO: Use class rather than class name
    def argument_class_name
      type_info.argument_class_name
    end

    def array_size
      if @length_arg
        @length_arg.retname
      else
        type_info.array_fixed_size
      end
    end

    def safe name
      if KEYWORDS.include? name
        "#{name}_"
      else
        name
      end
    end

    def inarg
      @array_arg.nil? ? @inarg : nil
    end

    def retval
      @array_arg.nil? ? retname : nil
    end

    def callarg
      @callarg ||= @var_gen.new_var
    end

    def pre
      []
    end

    def post
      []
    end

    def cleanup
      []
    end

    def new_variable
      @var_gen.new_var
    end

    private

    def outgoing_conversion base
      args = output_conversion_arguments base
      case specialized_type_tag
      when :utf8
        "#{base}.to_utf8"
      else
        "#{argument_class_name}.wrap(#{args})"
      end
    end

    def output_conversion_arguments arg
      if specialized_type_tag == :c
        "#{type_info.subtype_tag_or_class.inspect}, #{array_size}, #{arg}"
      else
        conversion_arguments arg
      end
    end

    def conversion_arguments name
      type_info.extra_conversion_arguments.map(&:inspect).push(name).join(", ")
    end
  end
end
