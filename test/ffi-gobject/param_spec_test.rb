# frozen_string_literal: true
require 'gir_ffi_test_helper'

require 'ffi-gobject'
describe GObject::ParamSpec do
  describe '#ref' do
    it 'increases the ref count' do
      pspec = GObject.param_spec_boolean('foo', 'foo bar',
                                         'Boolean Foo Bar',
                                         false,
                                         readable: true, writable: true)

      old = pspec.ref_count
      pspec.ref
      pspec.ref_count.must_equal old + 1
    end
  end

  describe '#accessor_name' do
    it 'returns a safe ruby method name' do
      pspec = GObject.param_spec_boolean('foo-bar', 'foo bar',
                                         'Boolean Foo Bar',
                                         false,
                                         readable: true, writable: true)

      pspec.accessor_name.must_equal 'foo_bar'
    end
  end

  it 'cannot be instantiated directly' do
    proc { GObject::ParamSpec.new }.must_raise NoMethodError
  end
end
