require 'gir_ffi_test_helper'

GirFFI.setup :Regress

# Tests deriving Ruby classes from GObject classes.
describe 'For derived classes' do
  describe 'setting up methods when first called' do
    before do
      save_module :GIMarshallingTests
      GirFFI.setup :GIMarshallingTests
    end

    describe 'when an interface is mixed in' do
      before do
        @klass = Class.new GIMarshallingTests::OverridesObject
        @klass.send :include, GIMarshallingTests::Interface
      end

      it 'finds class methods in the superclass' do
        @klass.returnv
      end

      it 'finds instance methods in the superclass' do
        obj = @klass.new
        result = obj.method
        result.must_equal 42
      end
    end

    after do
      restore_module :GIMarshallingTests
    end
  end

  describe 'the initializer' do
    it 'works if it calls super' do
      klass = Class.new Regress::TestSubObj do
        attr_reader :animal
        def initialize animal
          super()
          @animal = animal
        end
      end

      obj = klass.new 'dog'
      obj.must_be_instance_of klass
      obj.to_ptr.wont_be_nil
      obj.animal.must_equal 'dog'
    end
  end
end
