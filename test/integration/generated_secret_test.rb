require 'gir_ffi_test_helper'

GirFFI.setup :Secret

describe Secret do
  describe Secret::Schema do
    it "has a working constructor" do
      Secret::Schema.new("foo", :none, "bar" => :string)
    end
  end
end
