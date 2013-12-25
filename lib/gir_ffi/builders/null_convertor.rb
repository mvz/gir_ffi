class GirFFI::Builders::NullConvertor
  def initialize argument_name
    @argument_name = argument_name
  end

  def conversion
    @argument_name
  end
end
