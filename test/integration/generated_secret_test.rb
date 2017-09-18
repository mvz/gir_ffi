# frozen_string_literal: true

require 'gir_ffi_test_helper'

describe 'The generated Secret module' do
  describe 'Secret::Schema' do
    it 'has a working constructor' do
      begin
        GirFFI.setup :Secret
      rescue RuntimeError
        skip 'No GIR data for Secret available'
      end
      instance = Secret::Schema.new('foo', :none, 'bar' => :string)
      instance.must_be_instance_of Secret::Schema
    end
  end
end
