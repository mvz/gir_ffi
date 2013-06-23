require 'introspection_test_helper'

describe GObjectIntrospection::IEnumInfo do
  describe "#find_method" do
    setup do
      gir = GObjectIntrospection::IRepository.default
      gir.require 'Regress', nil
      @info = gir.find_by_name 'Regress', 'TestEnum'
    end

    should "find a method by name" do
      result = @info.find_method("param")
      result.name.must_equal "param"
    end
  end
end

