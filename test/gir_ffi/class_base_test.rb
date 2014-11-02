require 'gir_ffi_test_helper'

describe GirFFI::ClassBase do
  describe "a simple descendant" do
    let(:klass) {
      Class.new(GirFFI::ClassBase) do
        self::Struct = Class.new(FFI::Struct) do
          layout :foo, :int32
        end
      end
    }
    let(:object) { klass.wrap FFI::MemoryPointer.new(:int32) }

    it "has #from as a pass-through method" do
      result = klass.from :foo
      result.must_equal :foo
    end

    describe "#==" do
      it "returns true when comparing to an object of the same class and pointer" do
        other = klass.wrap object.to_ptr

        object.must_be :==, other
        other.must_be :==, object
      end

      it "returns true when comparing to an object of the same class and a pointer with the same address" do
        ptr = FFI::Pointer.new object.to_ptr
        other = klass.wrap ptr

        object.must_be :==, other
        other.must_be :==, object
      end

      it "returns false when comparing to an object of a sub/superclass and the same pointer" do
        subclass = Class.new(klass)
        other = subclass.wrap object.to_ptr

        object.wont_be :==, other
        other.wont_be :==, object
      end

      it "returns false when comparing to an object of the same class and different pointer" do
        other = klass.wrap FFI::MemoryPointer.new(:int32)

        object.wont_be :==, other
        other.wont_be :==, object
      end

      it "returns false when comparing to an object that doesn't respond to #to_ptr" do
        other = Object.new

        object.wont_be :==, other
        other.wont_be :==, object
      end

      it "returns false when comparing to an object of a different class and same pointer" do
        stub(other = Object.new).to_ptr { object.to_ptr }

        object.wont_be :==, other
        other.wont_be :==, object
      end

      it "returns false when comparing to an object of a different class and different pointer" do
        stub(other = Object.new).to_ptr { FFI::MemoryPointer.new(:int32) }

        object.wont_be :==, other
        other.wont_be :==, object
      end
    end
  end

  describe ".setup_and_call" do
    it "looks up class methods in all builders" do
      mock(builder = Object.new).setup_method("foo") { "foo" }
      klass = Class.new GirFFI::ClassBase
      klass.const_set :GIR_FFI_BUILDER, builder

      mock(sub_builder = Object.new).setup_method("foo") { nil }
      sub_klass = Class.new klass do
        def self.foo; end
      end
      sub_klass.const_set :GIR_FFI_BUILDER, sub_builder

      sub_klass.setup_and_call :foo, []
    end

    it "calls the method given by the result of .setup_method" do
      mock(builder = Object.new).setup_method("foo") { "bar" }
      klass = Class.new GirFFI::ClassBase do
        def self.bar
          "correct-result"
        end
        def self.new
          _real_new
        end
      end
      klass.const_set :GIR_FFI_BUILDER, builder

      result = klass.setup_and_call :foo, []
      result.must_equal "correct-result"
    end
  end

  describe "#setup_and_call" do
    it "looks up instance methods in all builders" do
      mock(builder = Object.new).setup_instance_method("foo") { "foo" }
      klass = Class.new GirFFI::ClassBase
      klass.const_set :GIR_FFI_BUILDER, builder

      mock(sub_builder = Object.new).setup_instance_method("foo") { nil }
      sub_klass = Class.new klass do
        def foo; end

        def initialize; end
        def self.new
          _real_new
        end
      end
      sub_klass.const_set :GIR_FFI_BUILDER, sub_builder

      obj = sub_klass.new

      obj.setup_and_call :foo, []
    end

    it "calls the method given by the result of .setup_instance_method" do
      mock(builder = Object.new).setup_instance_method("foo") { "bar" }
      klass = Class.new GirFFI::ClassBase do
        def bar
          "correct-result"
        end
        def self.new
          _real_new
        end
      end
      klass.const_set :GIR_FFI_BUILDER, builder

      obj = klass.new

      result = obj.setup_and_call :foo, []
      result.must_equal "correct-result"
    end
  end
end
