require 'introspection_test_helper'

describe GObjectIntrospection::IBaseInfo do
  let(:described_class) { GObjectIntrospection::IBaseInfo }
  describe "#initialize" do
    it "raises an error if nil is passed" do
      proc { described_class.new nil }.must_raise ArgumentError
    end

    it "raises an error if a null pointer is passed" do
      mock(ptr = Object.new).null? { true }
      proc { described_class.new ptr }.must_raise ArgumentError
    end

    it "raises no error if a non-null pointer is passed" do
      mock(ptr = Object.new).null? { false }
      described_class.new ptr
      pass
    end
  end

  describe "upon garbage collection" do
    it "calls g_base_info_unref" do
      mock(ptr = Object.new).null? { false }
      mock(ptr).null? { false }
      mock(lib = Object.new).g_base_info_unref(ptr) { nil }

      described_class.new ptr, lib

      # Yes, the next two lines are needed. https://gist.github.com/4277829
      stub(lib).g_base_info_unref(ptr) { nil }
      described_class.new ptr, lib

      GC.start
    end
  end
end

