require 'test_helper'

require 'ffi-gobject_introspection'

class MiniTest::Unit::TestCase
  def get_introspection_data namespace, name
    gir = GObjectIntrospection::IRepository.default
    gir.require namespace, nil
    gir.find_by_name namespace, name
  end
end
