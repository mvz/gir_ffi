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

    TAG_TO_WRAPPER_CLASS_MAP = {
      :array => 'GLib::Array',
      :byte_array => 'GLib::ByteArray',
      :c => 'GLib::SizedArray',
      :callback => 'GirFFI::Callback',
      :ghash => 'GLib::HashTable',
      :glist => 'GLib::List',
      :gslist => 'GLib::SList',
      :ptr_array => 'GLib::PtrArray',
      :strv => 'GLib::Strv',
      :utf8 => 'GirFFI::InPointer',
      :void => 'GirFFI::InPointer',
      :zero_terminated => 'GirFFI::ZeroTerminated'
    }

    # TODO: Use class rather than class name
    def argument_class_name
      case (tag = type_info.flattened_tag)
      when :struct, :union, :object, :interface, :enum, :flags
        type_info.interface_type_name
      else
        TAG_TO_WRAPPER_CLASS_MAP[tag]
      end
    end

    def subtype_tag_or_class_name
      type_info.subtype_tag_or_class_name
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

    private

    def conversion_arguments name
      case specialized_type_tag
      when :utf8, :void
        "#{specialized_type_tag.inspect}, #{name}"
      when :c
        "#{subtype_tag_or_class_name}, #{type_info.array_fixed_size}, #{name}"
      when :glist, :gslist, :ghash, :array, :zero_terminated
        "#{elm_t}, #{name}"
      when :callback
        iface = type_info.interface
        "\"#{iface.namespace}\", \"#{iface.name}\", #{name}"
      else
        "#{name}"
      end
    end
  end
end
