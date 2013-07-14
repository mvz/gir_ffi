require 'base_test_helper'

describe GLib::Strv do
  describe "#==" do
    it "returns true when comparing to an array with the same elements" do
      list = GLib::Strv.from ["1", "2", "3"]

      list.must_be :==, ["1", "2", "3"]
    end

    it "returns false when comparing to an array with different elements" do
      list = GLib::Strv.from ["1", "2", "3"]

      list.wont_be :==, ["1", "2"]
    end

    it "returns true when comparing to a strv with the same elements" do
      list = GLib::Strv.from ["1", "2", "3"]
      other = GLib::Strv.from ["1", "2", "3"]

      list.must_be :==, other
    end

    it "returns false when comparing to a strv with different elements" do
      list = GLib::Strv.from ["1", "2", "3"]
      other = GLib::Strv.from ["1", "2"]

      list.wont_be :==, other
    end
  end
end
