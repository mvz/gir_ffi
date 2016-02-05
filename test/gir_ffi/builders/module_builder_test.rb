# frozen_string_literal: true
require 'gir_ffi_test_helper'

describe GirFFI::Builders::ModuleBuilder do
  let(:gir) { GObjectIntrospection::IRepository.default }

  describe '#find_namespaced_class_info' do
    it 'finds the info in the GIR' do
      allow(gir).to receive(:require).with('Foo', nil)

      builder = GirFFI::Builders::ModuleBuilder.new 'Foo'

      expect(gir).to receive(:find_by_name).with('Foo', 'Bar').and_return 'gir info'

      builder.find_namespaced_class_info(:Bar).must_equal 'gir info'
    end

    it 'checks downcased class name as an alternative' do
      allow(gir).to receive(:require).with('Foo', nil)

      builder = GirFFI::Builders::ModuleBuilder.new 'Foo'

      expect(gir).to receive(:find_by_name).with('Foo', 'Bar').and_return nil
      expect(gir).to receive(:find_by_name).with('Foo', 'bar').and_return 'gir info'

      builder.find_namespaced_class_info(:Bar).must_equal 'gir info'
    end

    it 'raises a clear error if the named class does not exist' do
      allow(gir).to receive(:require).with('Foo', nil)

      builder = GirFFI::Builders::ModuleBuilder.new 'Foo'

      expect(gir).to receive(:find_by_name).with('Foo', 'Bar').and_return nil
      expect(gir).to receive(:find_by_name).with('Foo', 'bar').and_return nil

      assert_raises NameError do
        builder.find_namespaced_class_info :Bar
      end
    end
  end
end
