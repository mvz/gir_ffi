require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

# Tests how methods are looked up and generated on first use.
describe "Looking up methods" do
  before do
    save_module :Regress
    GirFFI.setup :Regress
  end

  describe "an instance method" do
    it "is found from a subclass" do
      defined_in_subclass =
        Regress::TestSubObj.instance_methods(false).map &:to_s

      defined_in_subclass.wont_include 'forced_method'

      sub_object = Regress::TestSubObj.new

      sub_object.forced_method
    end
  end

  describe "a class method" do
    it "is found from a subclass" do
      defined_in_subclass =
        Regress::TestSubObj.singleton_methods(false).map &:to_s

      defined_in_subclass.wont_include 'static_method'

      defined_in_class =
        Regress::TestObj.singleton_methods(false).map &:to_s

      defined_in_class.must_include 'static_method'

      Regress::TestSubObj.static_method 42
    end
  end

  after do
    restore_module :Regress
  end
end
