class GirFFI::Builders::ClosureConvertor
  def initialize argument_name
    @argument_name = argument_name
  end

  def conversion
    "GirFFI::ArgHelper::OBJECT_STORE[#{@argument_name}.address]"
  end
end
