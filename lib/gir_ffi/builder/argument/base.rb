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

        attr_reader :name, :retname

        attr_accessor :length_arg, :array_arg

        def initialize var_gen, name, typeinfo, direction
          @typeinfo = typeinfo
          @inarg = nil
          @retname = nil
          @name = safe(name)
          @var_gen = var_gen
          @length_arg = nil
          @array_arg = nil
        end

        def type_info
          @typeinfo
        end

        def type_tag
          type_info.tag
        end

        def specialized_type_tag
          case type_tag
          when :interface
            interface_type
          when :array
            array_type
          else
            type_tag
          end
        end

        def interface_type
          type_info.interface.info_type
        end

        def array_type
          if type_info.zero_terminated?
            :strv
          else
            type_info.array_type
          end
        end

        TAG_TO_WRAPPER_CLASS_MAP = {
          :glist => 'GLib::List',
          :gslist => 'GLib::SList',
          :ghash => 'GLib::HashTable',
          :array => 'GLib::Array',
          :utf8 => 'GirFFI::InPointer',
          :void => 'GirFFI::InPointer'
        }

        def argument_class_name
          case (tag = type_tag)
          when :interface
            iface = type_info.interface
            # FIXME: Extract to ITypeInfo.
            "::#{iface.safe_namespace}::#{iface.name}"
          when :array
            if type_info.zero_terminated?
              # TODO: Move under array_type :c
              'GLib::Strv'
            else
              case type_info.array_type
              when :byte_array
                'GLib::ByteArray'
              when :array
                'GLib::Array'
              else
                'GLib::PtrArray'
              end
            end
          else
            TAG_TO_WRAPPER_CLASS_MAP[tag]
          end
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

        def elm_t
          type_info.element_type.inspect
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

        def callarg
          @callarg ||= @var_gen.new_var
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

