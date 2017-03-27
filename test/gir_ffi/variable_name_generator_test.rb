# frozen_string_literal: true

require 'gir_ffi_test_helper'

require 'gir_ffi/variable_name_generator'

describe GirFFI::VariableNameGenerator do
  describe '#new_var' do
    it 'generates a sequence of predictable variable names' do
      gen = GirFFI::VariableNameGenerator.new

      assert_equal '_v1', gen.new_var
      assert_equal '_v2', gen.new_var
      assert_equal '_v3', gen.new_var
      assert_equal '_v4', gen.new_var
    end
  end
end
