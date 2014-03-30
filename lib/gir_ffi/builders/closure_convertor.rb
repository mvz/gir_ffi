class GirFFI::Builders::ClosureConvertor
  def initialize argument_name
    @argument_name = argument_name
  end

  def conversion
    "GirFFI::ArgHelper::OBJECT_STORE.fetch(#{@argument_name})"
  end
end
