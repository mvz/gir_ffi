# frozen_string_literal: true

require 'gir_ffi_test_helper'
require 'gir_ffi/user_defined_object_info'

GirFFI.setup :GIMarshallingTests

describe GirFFI::UserDefinedObjectInfo do
  describe '#described_class' do
    let(:info) { GirFFI::UserDefinedObjectInfo.new :some_class }

    it 'returns the class passed to #initialize' do
      info.described_class.must_equal :some_class
    end
  end

  describe '#install_property' do
    let(:info) { GirFFI::UserDefinedObjectInfo.new :some_class }
    let(:foo_spec) { Object.new }

    it 'adds the passed in property to the list of properties' do
      expect(foo_spec).to receive(:get_name).and_return :foo

      info.install_property foo_spec
      info.properties.map(&:name).must_equal [:foo]
    end
  end

  describe '#install_vfunc_implementation' do
    let(:info) { GirFFI::UserDefinedObjectInfo.new :some_class }
    let(:implementation) { Object.new }

    it 'adds to the list of vfunc implementations' do
      info.vfunc_implementations.must_equal []
      info.install_vfunc_implementation :foo, implementation
      info.vfunc_implementations.map(&:name).must_equal [:foo]
    end

    it 'stores the passed-in implementation in the implementation object' do
      info.install_vfunc_implementation :foo, implementation
      impl = info.vfunc_implementations.first
      impl.implementation.must_equal implementation
    end

    it 'provides a default implementation' do
      info.install_vfunc_implementation :foo
      impl = info.vfunc_implementations.first
      impl.implementation.class.must_equal Proc
    end
  end

  describe '#initialize' do
    let(:foo_spec) { Object.new }
    let(:bar_spec) { Object.new }
    let(:info) do
      GirFFI::UserDefinedObjectInfo.new :some_class do |inf|
        inf.install_property foo_spec
        inf.install_property bar_spec
      end
    end

    before do
      expect(foo_spec).to receive(:get_name).and_return :foo
      expect(bar_spec).to receive(:get_name).and_return :bar
    end

    it 'yields the new object to the block passed' do
      info.properties.map(&:name).must_equal [:foo, :bar]
    end
  end

  describe '#g_name' do
    let(:user_class) { Object.new }
    let(:info) { GirFFI::UserDefinedObjectInfo.new user_class }

    before do
      allow(user_class).to receive(:name).and_return 'foo'
    end

    it "returns the described class' name by default" do
      info.g_name.must_equal 'foo'
    end

    it 'returns the the name set by #g_name= if present' do
      info.g_name = 'bar'
      info.g_name.must_equal 'bar'
    end
  end

  describe '#find_method' do
    let(:user_class) { Object.new }
    let(:info) { GirFFI::UserDefinedObjectInfo.new user_class }

    it 'finds no methods' do
      info.find_method('foo').must_be_nil
    end
  end

  describe '#find_signal' do
    let(:user_class) { Object.new }
    let(:info) { GirFFI::UserDefinedObjectInfo.new user_class }

    it 'finds no signals' do
      info.find_signal('foo').must_be_nil
    end
  end

  describe '#interfaces' do
    let(:modul) { GIMarshallingTests::Interface }
    let(:user_class) { Class.new GIMarshallingTests::Object }
    let(:info) { GirFFI::UserDefinedObjectInfo.new user_class }

    before do
      user_class.send :include, modul
    end

    it 'returns the interface infos for the include modules' do
      info.interfaces.must_equal [modul.gir_info]
    end
  end
end
