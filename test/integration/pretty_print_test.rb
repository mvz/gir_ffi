require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

describe "Pretty-printing the Regress module" do
  before do
    GirFFI.setup :Regress
  end

  it "runs without throwing an exception" do
    Regress._builder.pretty_print
  end
end
