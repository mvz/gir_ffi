require 'base_test_helper'

describe GLib::Strv do
  describe "#==" do
    it "returns true when comparing to an array with the same elements" do
      strv = GLib::Strv.from ["1", "2", "3"]

      strv.must_be :==, ["1", "2", "3"]
    end

    it "returns false when comparing to an array with different elements" do
      strv = GLib::Strv.from ["1", "2", "3"]

      strv.wont_be :==, ["1", "2"]
    end

    it "returns true when comparing to a strv with the same elements" do
      strv = GLib::Strv.from ["1", "2", "3"]
      other = GLib::Strv.from ["1", "2", "3"]

      strv.must_be :==, other
    end

    it "returns false when comparing to a strv with different elements" do
      strv = GLib::Strv.from ["1", "2", "3"]
      other = GLib::Strv.from ["1", "2"]

      strv.wont_be :==, other
    end
  end
end
