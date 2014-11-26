require 'introspection_test_helper'

describe GObjectIntrospection::IBaseInfo do
  let(:described_class) { GObjectIntrospection::IBaseInfo }
  describe '#initialize' do
    it 'raises an error if a null pointer is passed' do
      mock(ptr = Object.new).null? { true }
      proc { described_class.new ptr }.must_raise ArgumentError
    end

    it 'raises no error if a non-null pointer is passed' do
      mock(ptr = Object.new).null? { false }
      described_class.new ptr
      pass
    end
  end

  describe '#deprecated?' do
    let(:deprecated_info) { get_introspection_data 'Regress', 'test_versioning' }
    let(:other_info) { get_introspection_data 'Regress', 'test_value_return' }

    it 'returns true for a deprecated item' do
      skip unless deprecated_info
      deprecated_info.must_be :deprecated?
    end

    it 'returns false for a non-deprecated item' do
      other_info.wont_be :deprecated?
    end
  end

  describe 'upon garbage collection' do
    it 'calls g_base_info_unref' do
      if defined?(RUBY_ENGINE) && %w(jruby rbx).include?(RUBY_ENGINE)
        skip 'cannot be reliably tested on JRuby and Rubinius'
      end

      mock(ptr = Object.new).null? { false }
      mock(lib = Object.new).g_base_info_unref(ptr) { nil }
      described_class.new ptr, lib

      GC.start

      # Yes, the next three lines are needed. https://gist.github.com/4277829
      stub(ptr2 = Object.new).null? { false }
      stub(lib).g_base_info_unref(ptr2) { nil }
      described_class.new ptr2, lib

      GC.start
      GC.start
    end
  end
end
