require 'introspection_test_helper'

describe GObjectIntrospection::Lib::GIArgument do
  describe 'its member :v_ssize' do
    it 'is signed' do
      gia = GObjectIntrospection::Lib::GIArgument.new
      gia[:v_int64] = -1
      assert_equal(-1, gia[:v_ssize])
    end
  end
end
