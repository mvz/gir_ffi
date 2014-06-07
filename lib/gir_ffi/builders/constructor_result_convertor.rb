# Builds conversion code for the result of a GObject constructor method.
class GirFFI::Builders::ConstructorResultConvertor
  def initialize argument_name
    @argument_name = argument_name
  end

  def conversion
    "self.constructor_wrap(#{@argument_name})"
  end
end
