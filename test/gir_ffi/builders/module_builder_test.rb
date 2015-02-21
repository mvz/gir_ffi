require 'gir_ffi_test_helper'

describe GirFFI::Builders::ModuleBuilder do
  describe '#build_namespaced_class' do
    it 'raises a clear error if the named class does not exist' do
      gir = GObjectIntrospection::IRepository.default
      stub(gir).require('Foo', nil) {}

      builder = GirFFI::Builders::ModuleBuilder.new 'Foo'

      expect(gir).to receive(:find_by_name).with('Foo', 'Bar').and_return nil

      assert_raises NameError do
        builder.build_namespaced_class :Bar
      end
    end
  end
end
