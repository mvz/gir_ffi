require File.expand_path('test_helper.rb', File.dirname(__FILE__))

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
end
