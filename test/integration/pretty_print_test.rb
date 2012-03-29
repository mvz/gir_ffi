require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

require 'tempfile'

GirFFI.setup :Regress

describe "Pretty-printing" do
  def assert_syntax_ok str
    tmp = Tempfile.new "gir_ffi"
    # TODO: Make #pretty_print add this preamble.
    tmp.write "# coding: utf-8\n"
    tmp.write str
    tmp.flush
    is_ok = `ruby -c #{tmp.path} 2>&1`
    assert_equal "Syntax OK\n", is_ok
  end

  describe "for the Regress module" do
    it "runs without throwing an exception" do
      Regress._builder.pretty_print
    end

    it "results in valid Ruby" do
      assert_syntax_ok Regress._builder.pretty_print
    end
  end

  describe "for the GLib module" do
    it "results in valid Ruby" do
      assert_syntax_ok GLib._builder.pretty_print
    end
  end
end
