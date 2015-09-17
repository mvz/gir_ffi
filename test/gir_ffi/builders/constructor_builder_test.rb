require 'gir_ffi_test_helper'

require 'gir_ffi/builders/constructor_builder'

describe GirFFI::Builders::ConstructorBuilder do
  describe '#generate' do
    let(:builder) { GirFFI::Builders::ConstructorBuilder.new function_info }
    let(:code) { builder.generate }

    describe 'for constructors with the default name' do
      let(:function_info) { get_method_introspection_data 'Regress', 'TestObj', 'new' }
      it 'builds a constructor' do
        code.must_equal <<-CODE.reset_indentation
          def self.new(*args)
            obj = allocate
            obj.initialize(*args)
            obj
          end
        CODE
      end
    end

    describe 'for constructors with a custom name' do
      let(:function_info) { get_method_introspection_data 'Regress', 'TestObj', 'new_from_file' }
      it 'builds a custom constructor' do
        code.must_equal <<-CODE.reset_indentation
          def self.new_from_file(*args)
            obj = allocate
            obj.initialize_from_file(*args)
            obj
          end
        CODE
      end
    end
  end
end
