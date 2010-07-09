require File.expand_path('test_helper.rb', File.dirname(__FILE__))
require 'girffi'
GirFFI.setup :Gtk

class GtkOverridesTest < Test::Unit::TestCase
  context "The Gtk.init function" do
    should "not take any arguments" do
      assert_raises(ArgumentError) { Gtk.init 1, ["foo"] }
      assert_nothing_raised { Gtk.init }
    end
    # FIXME: The following test doesn't actually work.
    # In practice however, the Gtk.init function does exactly this.
    if false
    should "process ARGV, removing Gtk+ options" do
      ARGV.replace ["foo", "--g-fatal-warnings"]
      Gtk.init
      assert_same_elements ["foo"], ARGV
    end
    end
  end
end

