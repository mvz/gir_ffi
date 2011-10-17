require File.expand_path('gir_ffi_test_helper.rb', File.dirname(__FILE__))

describe "Gtk's overrides" do
  before do
    save_module :Gtk
    ::Object.const_set :Gtk, Module.new
    Gtk.class_eval do
      def self.init arr
        ["baz", "qux", "zonk"]
      end
    end
    stub(Gtk)._setup_method { }

    load 'ffi-gtk/base.rb'
  end

  context "The .init function" do
    should "not take any arguments" do
      assert_raises(ArgumentError) { Gtk.init 1, ["foo"] }
      assert_raises(ArgumentError) { Gtk.init ["foo"] }
      assert_nothing_raised { Gtk.init }
    end

    should "replace ARGV with the tail of the result of the original init function" do
      ARGV.replace ["foo", "bar"]
      Gtk.init
      assert_equal ["qux", "zonk"], ARGV.to_a
    end
  end

  after do
    restore_module :Gtk
  end
end

