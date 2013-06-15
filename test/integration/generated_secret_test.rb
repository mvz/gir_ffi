require 'gir_ffi_test_helper'

describe "The generated Secret module" do
  describe "Secret::Schema" do
    it "has a working constructor" do
      begin
        GirFFI.setup :Secret
      rescue
        skip "No GIR data for Secret available"
      end
      Secret::Schema.new("foo", :none, "bar" => :string)
    end
  end
end
