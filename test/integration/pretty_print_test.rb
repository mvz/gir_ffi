require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

require 'tempfile'

GirFFI.setup :Regress

describe "Pretty-printing" do
  describe "for the Regress module" do
    it "runs without throwing an exception" do
      Regress._builder.pretty_print
    end

    it "results in valid Ruby" do
      tmp = Tempfile.new "gir_ffi"
      tmp.write Regress._builder.pretty_print
      tmp.flush
      is_ok = `ruby -c #{tmp.path}`
      assert_equal "Syntax OK\n", is_ok
    end
  end
end
