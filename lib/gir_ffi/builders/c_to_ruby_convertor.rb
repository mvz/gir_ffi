# Builder that generates code to convert values from C to Ruby. Used by
# argument builders.
class GirFFI::Builders::CToRubyConvertor
  def initialize type_info, argument_name, length_arg
    @type_info = type_info
    @argument_name = argument_name
    @length_arg = length_arg
  end

  def conversion
    case @type_info.flattened_tag
    when :utf8, :filename
      "#{@argument_name}.to_utf8"
    else
      "#{@type_info.argument_class_name}.wrap(#{conversion_arguments})"
    end
  end

  private

  def conversion_arguments
    if @type_info.flattened_tag == :c
      "#{@type_info.element_type.inspect}, #{array_size}, #{@argument_name}"
    else
      @type_info.extra_conversion_arguments.map(&:inspect).push(@argument_name).join(', ')
    end
  end

  def array_size
    if @length_arg
      @length_arg
    else
      @type_info.array_fixed_size
    end
  end
end
