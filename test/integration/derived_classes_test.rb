# frozen_string_literal: true

require "gir_ffi_test_helper"

GirFFI.setup :Regress
GirFFI.setup :GIMarshallingTests

# Tests deriving Ruby classes from GObject classes.
describe "For derived classes" do
  describe "setting up methods when first called" do
    describe "when an interface is mixed in" do
      before do
        @klass = Class.new GIMarshallingTests::OverridesObject
        @klass.send :include, GIMarshallingTests::Interface
      end

      it "finds class methods in the superclass" do
        @klass.returnv
      end

      it "finds instance methods in the superclass" do
        obj = @klass.new
        result = obj.method

        _(result).must_equal 42
      end
    end
  end

  describe "the initializer" do
    it "works if it calls super" do
      klass = Class.new Regress::TestSubObj do
        attr_reader :animal

        def initialize(animal)
          super()
          @animal = animal
        end
      end

      obj = klass.new "dog"

      _(obj).must_be_instance_of klass
      _(obj.to_ptr).wont_be_nil
      _(obj.animal).must_equal "dog"
    end
  end
end
