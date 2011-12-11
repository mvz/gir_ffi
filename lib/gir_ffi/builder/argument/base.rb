module GirFFI
  module Builder
    module Argument
      # Abstract parent class of the argument building classes. These
      # classes are used by Builder::Function to create the code that
      # processes each argument before and after the actual function call.
      class Base
        KEYWORDS = [
          "alias", "and", "begin", "break", "case", "class", "def", "do",
          "else", "elsif", "end", "ensure", "false", "for", "if", "in",
          "module", "next", "nil", "not", "or", "redo", "rescue", "retry",
          "return", "self", "super", "then", "true", "undef", "unless",
          "until", "when", "while", "yield"
        ]

        attr_reader :callarg, :name, :retname

        attr_accessor :length_arg, :array_arg

        def initialize var_gen, name, typeinfo
          @typeinfo = typeinfo
          @inarg = nil
          @callarg = nil
          @retname = nil
          @name = safe(name)
          @var_gen = var_gen
          @length_arg = nil
          @array_arg = nil
        end

        def prepare; end

        def type_info
          @typeinfo
        end

        def type_tag
          tag = type_info.tag
          tag == :GType ? :gtype : tag
        end

        def subtype_tag index=0
          st = type_info.param_type(index)
          t = st.tag
          case t
          when :GType
            return :gtype
          when :interface
            return :interface_pointer if st.pointer?
            return :interface
          else
            return t
          end
        end

        def argument_class_name
          iface = type_info.interface
          # FIXME: Extract to ITypeInfo.
          "::#{iface.safe_namespace}::#{iface.name}"
        end

        def subtype_tag_or_class_name index=0
          type = type_info.param_type(index)
          tag = type.tag
          base = if tag == :interface
                   iface = type.interface
                   "::#{iface.safe_namespace}::#{iface.name}"
                 else
                   tag.inspect
                 end
          if type.pointer?
            "[:pointer, #{base}]"
          else
            base
          end
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
          @array_arg.nil? ? @retname : nil
        end

        def pre
          []
        end

        def post
          []
        end

        def postpost
          []
        end

        def cleanup
          []
        end
      end
    end
  end
end

