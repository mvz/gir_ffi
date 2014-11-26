require 'gir_ffi_test_helper'

describe GLib::Variant do
  describe '#get_string' do
    it 'returns just the contained string' do
      var = GLib::Variant.new_string('Foo')
      var.get_string.must_equal 'Foo'
    end
  end
end
