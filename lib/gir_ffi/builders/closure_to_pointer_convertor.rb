class GirFFI::Builders::ClosureToPointerConvertor
  def initialize argument_name
    @argument_name = argument_name
  end

  def conversion
    "GirFFI::InPointer.from_closure_data(#{@argument_name})"
  end
end
