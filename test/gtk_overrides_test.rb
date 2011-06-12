require File.expand_path('test_helper.rb', File.dirname(__FILE__))
require 'gir_ffi/overrides/gtk'

describe GirFFI::Overrides::Gtk do
  before do
    @gtk = Module.new do
      def self.init arr
        ["baz", "qux", "zonk"]
      end
    end
    stub(@gtk)._setup_method { }

    @gtk.instance_eval do
      include GirFFI::Overrides::Gtk
    end
  end

  context "The .init function" do
    should "not take any arguments" do
      assert_raises(ArgumentError) { @gtk.init 1, ["foo"] }
      assert_raises(ArgumentError) { @gtk.init ["foo"] }
      assert_nothing_raised { @gtk.init }
    end

    should "replace ARGV with the tail of the result of the original init function" do
      ARGV.replace ["foo", "bar"]
      @gtk.init
      assert_equal ["qux", "zonk"], ARGV.to_a
    end
  end
end

