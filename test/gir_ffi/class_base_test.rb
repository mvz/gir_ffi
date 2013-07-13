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

        (object == other).must_equal true
      end

      it "returns false when comparing to an object of the same class and different pointer" do
        other = klass.wrap FFI::MemoryPointer.new(:int32)

        (object == other).must_equal false
      end

      it "returns true when comparing to an object of a different class and same pointer" do
        stub(other = Object.new).to_ptr { object.to_ptr }

        (object == other).must_equal true
      end

      it "returns false when comparing to an object of a different class and different pointer" do
        stub(other = Object.new).to_ptr { FFI::MemoryPointer.new(:int32) }

        (object == other).must_equal false
      end
    end

    describe "#eql?" do
      it "returns true when comparing to an object of the same class and pointer" do
        other = klass.wrap object.to_ptr

        object.must_equal other
      end

      it "returns false when comparing to an object of the same class and different pointer" do
        other = klass.wrap FFI::MemoryPointer.new(:int32)

        object.wont_equal other
      end

      it "returns true when comparing to an object of a different class and same pointer" do
        stub(other = Object.new).to_ptr { object.to_ptr }

        object.wont_equal other
      end

      it "returns false when comparing to an object of a different class and different pointer" do
        stub(other = Object.new).to_ptr { FFI::MemoryPointer.new(:int32) }

        object.wont_equal other
      end
    end
  end

  describe "a descendant with multiple builders" do
    it "looks up class methods in all builders" do
      mock(builder = Object.new).setup_method("foo") { true }
      klass = Class.new GirFFI::ClassBase
      klass.const_set :GIR_FFI_BUILDER, builder

      mock(sub_builder = Object.new).setup_method("foo") { false }
      sub_klass = Class.new klass do
        def self.foo; end
      end
      sub_klass.const_set :GIR_FFI_BUILDER, sub_builder

      sub_klass.setup_and_call :foo
    end

    it "looks up class methods in all builders" do
      mock(builder = Object.new).setup_instance_method("foo") { true }
      klass = Class.new GirFFI::ClassBase
      klass.const_set :GIR_FFI_BUILDER, builder

      mock(sub_builder = Object.new).setup_instance_method("foo") { false }
      sub_klass = Class.new klass do
        def foo; end
        def initialize; end
        def self.new; self._real_new; end
      end
      sub_klass.const_set :GIR_FFI_BUILDER, sub_builder

      obj = sub_klass.new

      obj.setup_and_call :foo
    end
  end
end
