require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

describe GirFFI::Builder::Function do
  describe "#pretty_print" do
    it "delegates to #generate" do
      builder = GirFFI::Builder::Function.new(:info, :libmodule)

      mock(builder).generate { 'result_from_generate' }

      assert_equal "result_from_generate", builder.pretty_print
    end
  end

  it "builds a correct definition of Regress:test_array_fixed_out_objects" do
    go = get_introspection_data 'Regress', 'test_array_fixed_out_objects'
    fbuilder = GirFFI::Builder::Function.new go, Lib
    code = fbuilder.generate

    expected =
      "def test_array_fixed_out_objects
        _v1 = GirFFI::InOutPointer.for_array [:pointer, ::Regress::TestObj]
        ::Lib.regress_test_array_fixed_out_objects _v1
        _v2 = _v1.to_sized_array_value 2
        return _v2
      end"

    assert_equal cws(expected), cws(code)
  end

end




