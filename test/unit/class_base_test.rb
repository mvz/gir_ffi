require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

describe GirFFI::ClassBase do
  describe "a simple descendant" do
    before do
      @klass = Class.new GirFFI::ClassBase
    end

    it "has #from as a pass-through method" do
      result = @klass.from :foo
      result.must_equal :foo
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
