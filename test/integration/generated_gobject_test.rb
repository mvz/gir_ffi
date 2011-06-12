require File.expand_path('../test_helper.rb', File.dirname(__FILE__))

describe "The generated GObject module" do
  before do
    GirFFI.setup :GObject
  end

  describe "#type_interfaces" do
    it "works, showing that returning an array of GType works" do
      tp = GObject.type_from_name 'GTypeModule'
      ifcs = GObject.type_interfaces tp
      assert_equal 1, ifcs.size
    end
  end

  describe "the TypePlugin interface" do
    it "is implemented as a module" do
      mod = GObject::TypePlugin
      assert_instance_of Module, mod
      refute_instance_of Class, mod
    end
  end

  describe "the TypeModule class" do
    it "has the GObject::TypePlugin module as an ancestor" do
      klass = GObject::TypeModule
      assert_includes klass.ancestors, GObject::TypePlugin
    end
  end
end
