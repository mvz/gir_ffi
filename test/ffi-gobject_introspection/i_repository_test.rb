# frozen_string_literal: true
require 'introspection_test_helper'

describe GObjectIntrospection::IRepository do
  let(:gir) { GObjectIntrospection::IRepository.default }

  describe 'an instance' do
    it 'is not created by calling new()' do
      assert_raises NoMethodError do
        GObjectIntrospection::IRepository.new
      end
    end

    it 'is created by calling default()' do
      assert_kind_of GObjectIntrospection::IRepository, gir
    end

    it 'is a singleton' do
      gir2 = GObjectIntrospection::IRepository.default
      assert_equal gir, gir2
    end
  end

  describe '#require' do
    it "raises an error if the namespace doesn't exist" do
      assert_raises RuntimeError do
        gir.require 'VeryUnlikelyGObjectNamespaceName', nil
      end
    end

    it 'allows version to be nil' do
      gir.require 'GObject', nil
      pass
    end

    it 'allows version to be left out' do
      gir.require 'GObject'
      pass
    end
  end

  describe '#find_by_gtype' do
    it 'raises an error if 0 is passed as the gtype' do
      proc { gir.find_by_gtype 0 }.must_raise ArgumentError
    end
  end

  describe '#n_infos' do
    it 'yields more than one object for the GObject namespace' do
      gir.require 'GObject', '2.0'
      assert_operator gir.n_infos('GObject'), :>, 0
    end
  end

  describe '#info' do
    it 'yields IBaseInfo objects' do
      gir.require 'GObject', '2.0'
      assert_kind_of GObjectIntrospection::IBaseInfo, gir.info('GObject', 0)
    end
  end

  describe '#dependencies' do
    it 'returns a list of dependencies of the given namespace' do
      result = gir.dependencies('GObject')
      result.must_equal ['GLib-2.0']
    end

    it 'passes its struct pointer to the c function just in case' do
      ptr = gir.instance_variable_get(:@gobj)
      allow(GObjectIntrospection::Lib).to receive(:g_irepository_get_dependencies).
        and_call_original

      gir.dependencies('GObject')

      expect(GObjectIntrospection::Lib).to have_received(:g_irepository_get_dependencies).
        with(ptr, 'GObject')
    end
  end
end
