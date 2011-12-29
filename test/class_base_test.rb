require File.expand_path('gir_ffi_test_helper.rb', File.dirname(__FILE__))

class ClassBaseTest < MiniTest::Spec
  describe "A class derived from GirFFI::Base" do
    it "has #from as a pass-through method" do
      klass = Class.new GirFFI::ClassBase

      result = klass.from :foo
      result.must_equal :foo
    end
  end
end
