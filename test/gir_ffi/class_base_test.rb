# frozen_string_literal: true

require "gir_ffi_test_helper"

describe GirFFI::ClassBase do
  describe "a simple descendant" do
    let(:class_struct) do
      Class.new(GirFFI::ClassBase) do
        self::Struct = Class.new(GirFFI::Struct) do
          layout :foo, :int32
        end
      end
    end
    let(:object) { class_struct.wrap FFI::MemoryPointer.new(:int32) }

    it "has #from as a pass-through method" do
      result = class_struct.from :foo
      _(result).must_equal :foo
    end

    describe "#==" do
      it "returns true for an object of the same class and pointer" do
        other = class_struct.wrap object.to_ptr

        _(object).must_be :==, other
        _(other).must_be :==, object
      end

      it "returns true for an object of the same class and pointer with the same address" do
        ptr = FFI::Pointer.new object.to_ptr
        other = class_struct.wrap ptr

        _(object).must_be :==, other
        _(other).must_be :==, object
      end

      it "returns false for an object of a sub/superclass and the same pointer" do
        subclass = Class.new(class_struct)
        other = subclass.wrap object.to_ptr

        _(object).wont_be :==, other
        _(other).wont_be :==, object
      end

      it "returns false for an object of the same class and different pointer" do
        other = class_struct.wrap FFI::MemoryPointer.new(:int32)

        _(object).wont_be :==, other
        _(other).wont_be :==, object
      end

      it "returns false for an object that doesn't respond to #to_ptr" do
        other = Object.new

        _(object).wont_be :==, other
        _(other).wont_be :==, object
      end

      it "returns false for an object of a different class and same pointer" do
        allow(other = Object.new).to receive(:to_ptr).and_return object.to_ptr

        _(object).wont_be :==, other
        _(other).wont_be :==, object
      end

      it "returns false for an object of a different class and different pointer" do
        allow(other = Object.new)
          .to receive(:to_ptr).and_return FFI::MemoryPointer.new(:int32)

        _(object).wont_be :==, other
        _(other).wont_be :==, object
      end
    end
  end

  describe ".setup_and_call" do
    it "looks up class methods in all builders" do
      expect(builder = Object.new).to receive(:setup_method).with("foo").and_return "foo"
      klass = Class.new GirFFI::ClassBase
      klass.const_set :GIR_FFI_BUILDER, builder

      expect(sub_builder = Object.new).to receive(:setup_method).with("foo").and_return nil
      sub_klass = Class.new klass do
        def self.foo; end
      end
      sub_klass.const_set :GIR_FFI_BUILDER, sub_builder

      sub_klass.setup_and_call :foo, []
    end

    it "calls the method given by the result of .setup_method" do
      expect(builder = Object.new).to receive(:setup_method).with("foo").and_return "bar"
      klass = Class.new GirFFI::ClassBase do
        def self.bar
          "correct-result"
        end
      end
      klass.const_set :GIR_FFI_BUILDER, builder

      result = klass.setup_and_call :foo, []
      _(result).must_equal "correct-result"
    end

    it "raises a sensible error if the method is not found" do
      expect(builder = Object.new).to receive(:setup_method).with("foo").and_return nil
      klass = Class.new GirFFI::ClassBase
      klass.const_set :GIR_FFI_BUILDER, builder

      exception = _(proc { klass.setup_and_call :foo, [] }).must_raise(NoMethodError)
      _(exception.message).must_match(/^undefined method `foo' for/)
    end
  end

  describe "#setup_and_call" do
    it "looks up instance methods in all builders" do
      expect(builder = Object.new)
        .to receive(:setup_instance_method).with("foo").and_return "foo"
      klass = Class.new GirFFI::ClassBase
      klass.const_set :GIR_FFI_BUILDER, builder

      expect(sub_builder = Object.new)
        .to receive(:setup_instance_method).with("foo").and_return nil
      sub_klass = Class.new klass do
        def foo; end
      end
      sub_klass.const_set :GIR_FFI_BUILDER, sub_builder

      obj = sub_klass.new

      obj.setup_and_call :foo, []
    end

    it "calls the method given by the result of .setup_instance_method" do
      expect(builder = Object.new)
        .to receive(:setup_instance_method).with("foo").and_return "bar"
      klass = Class.new GirFFI::ClassBase do
        def bar
          "correct-result"
        end
      end
      klass.const_set :GIR_FFI_BUILDER, builder

      obj = klass.new

      result = obj.setup_and_call :foo, []
      _(result).must_equal "correct-result"
    end

    it "raises a sensible error if the method is not found" do
      expect(builder = Object.new)
        .to receive(:setup_instance_method).with("foo").and_return nil
      klass = Class.new GirFFI::ClassBase
      klass.const_set :GIR_FFI_BUILDER, builder

      obj = klass.new

      exception = _(proc { obj.setup_and_call :foo, [] }).must_raise(NoMethodError)
      _(exception.message).must_match(/^undefined method `foo' for/)
    end
  end
end
