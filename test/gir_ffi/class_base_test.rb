# frozen_string_literal: true
require 'gir_ffi_test_helper'

describe GirFFI::ClassBase do
  describe 'a simple descendant' do
    let(:klass) do
      Class.new(GirFFI::ClassBase) do
        self::Struct = Class.new(FFI::Struct) do
          layout :foo, :int32
        end
      end
    end
    let(:object) { klass.wrap FFI::MemoryPointer.new(:int32) }

    it 'has #from as a pass-through method' do
      result = klass.from :foo
      result.must_equal :foo
    end

    describe '#==' do
      it 'returns true when comparing to an object of the same class and pointer' do
        other = klass.wrap object.to_ptr

        object.must_be :==, other
        other.must_be :==, object
      end

      it 'returns true when comparing to an object of the same class and a pointer with the same address' do
        ptr = FFI::Pointer.new object.to_ptr
        other = klass.wrap ptr

        object.must_be :==, other
        other.must_be :==, object
      end

      it 'returns false when comparing to an object of a sub/superclass and the same pointer' do
        subclass = Class.new(klass)
        other = subclass.wrap object.to_ptr

        object.wont_be :==, other
        other.wont_be :==, object
      end

      it 'returns false when comparing to an object of the same class and different pointer' do
        other = klass.wrap FFI::MemoryPointer.new(:int32)

        object.wont_be :==, other
        other.wont_be :==, object
      end

      it "returns false when comparing to an object that doesn't respond to #to_ptr" do
        other = Object.new

        object.wont_be :==, other
        other.wont_be :==, object
      end

      it 'returns false when comparing to an object of a different class and same pointer' do
        allow(other = Object.new).to receive(:to_ptr).and_return object.to_ptr

        object.wont_be :==, other
        other.wont_be :==, object
      end

      it 'returns false when comparing to an object of a different class and different pointer' do
        allow(other = Object.new).to receive(:to_ptr).and_return FFI::MemoryPointer.new(:int32)

        object.wont_be :==, other
        other.wont_be :==, object
      end
    end
  end

  describe '.setup_and_call' do
    it 'looks up class methods in all builders' do
      expect(builder = Object.new).to receive(:setup_method).with('foo').and_return 'foo'
      klass = Class.new GirFFI::ClassBase
      klass.const_set :GIR_FFI_BUILDER, builder

      expect(sub_builder = Object.new).to receive(:setup_method).with('foo').and_return nil
      sub_klass = Class.new klass do
        def self.foo; end
      end
      sub_klass.const_set :GIR_FFI_BUILDER, sub_builder

      sub_klass.setup_and_call :foo, []
    end

    it 'calls the method given by the result of .setup_method' do
      expect(builder = Object.new).to receive(:setup_method).with('foo').and_return 'bar'
      klass = Class.new GirFFI::ClassBase do
        def self.bar
          'correct-result'
        end

        def initialize
        end
      end
      klass.const_set :GIR_FFI_BUILDER, builder

      result = klass.setup_and_call :foo, []
      result.must_equal 'correct-result'
    end

    it 'raises a sensible error if the method is not found' do
      expect(builder = Object.new).to receive(:setup_method).with('foo').and_return nil
      klass = Class.new GirFFI::ClassBase do
        def initialize
        end
      end
      klass.const_set :GIR_FFI_BUILDER, builder

      proc { klass.setup_and_call :foo, [] }.
        must_raise(NoMethodError).message.
        must_match(/^undefined method `foo' for/)
    end
  end

  describe '#setup_and_call' do
    it 'looks up instance methods in all builders' do
      expect(builder = Object.new).to receive(:setup_instance_method).with('foo').and_return 'foo'
      klass = Class.new GirFFI::ClassBase
      klass.const_set :GIR_FFI_BUILDER, builder

      expect(sub_builder = Object.new).to receive(:setup_instance_method).with('foo').and_return nil
      sub_klass = Class.new klass do
        def foo
        end

        def initialize
        end
      end
      sub_klass.const_set :GIR_FFI_BUILDER, sub_builder

      obj = sub_klass.new

      obj.setup_and_call :foo, []
    end

    it 'calls the method given by the result of .setup_instance_method' do
      expect(builder = Object.new).to receive(:setup_instance_method).with('foo').and_return 'bar'
      klass = Class.new GirFFI::ClassBase do
        def bar
          'correct-result'
        end

        def initialize
        end
      end
      klass.const_set :GIR_FFI_BUILDER, builder

      obj = klass.new

      result = obj.setup_and_call :foo, []
      result.must_equal 'correct-result'
    end

    it 'raises a sensible error if the method is not found' do
      expect(builder = Object.new).to receive(:setup_instance_method).with('foo').and_return nil
      klass = Class.new GirFFI::ClassBase do
        def initialize
        end
      end
      klass.const_set :GIR_FFI_BUILDER, builder

      obj = klass.new

      proc { obj.setup_and_call :foo, [] }.
        must_raise(NoMethodError).message.
        must_match(/^undefined method `foo' for/)
    end
  end
end
