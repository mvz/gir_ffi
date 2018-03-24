# frozen_string_literal: true

require 'gir_ffi_test_helper'

# Tests generated classes, methods and functions in the GLib namespace.
describe 'The generated GLib module' do
  it 'can auto-generate the GLib::SOURCE_REMOVE constant' do
    skip unless get_introspection_data 'GLib', 'SOURCE_REMOVE'

    GLib::SOURCE_REMOVE.must_equal false
  end
end
