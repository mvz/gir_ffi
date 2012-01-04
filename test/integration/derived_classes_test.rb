require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

GirFFI.setup :Regress

class Sequence
  @@seq = 0
  def self.next
    @@seq += 1
  end
end

# Tests deriving Ruby classes from GObject classes.
describe "For derived classes" do
  describe "setting up methods when first called" do
    before do
      save_module :GIMarshallingTests
      GirFFI.setup :GIMarshallingTests
    end

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
        result.must_equal 42
      end
    end

    after do
      restore_module :GIMarshallingTests
    end
  end

  describe "the initializer" do
    it "does not have to call super" do
      klass = Class.new Regress::TestSubObj do
        def initialize *args
        end
      end

      obj = klass.new
      obj.must_be_instance_of klass
      obj.to_ptr.wont_be_nil
    end
  end

  describe "GObject.type_register" do
    before do
      @klass = Class.new GIMarshallingTests::OverridesObject
      Object.const_set "Derived#{Sequence.next}", @klass
      @gtype = GObject.type_register @klass
    end

    it "returns a GType for the derived class" do
      parent_gtype = GIMarshallingTests::OverridesObject.get_gtype
      @gtype.wont_equal parent_gtype
      GObject.type_name(@gtype).must_equal @klass.name
    end
  end
end
