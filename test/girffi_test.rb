require File.expand_path('test_helper.rb', File.dirname(__FILE__))

class GirFFITest < MiniTest::Spec
  context "GirFFI" do
    it "sets up cairo as Cairo" do
      GirFFI.setup :cairo
      assert Object.const_defined?(:Cairo)
    end

    it "sets up xlib, which has no shared library" do
      gir = GirFFI::IRepository.default
      gir.require 'xlib'
      assert_nil gir.shared_library('xlib'), "Precondition for test failed"
      GirFFI.setup :xlib
    end

    it "sets up dependencies" do
      cleanup_module :GObject
      cleanup_module :Regress
      GirFFI.setup :Regress
      assert Object.const_defined?(:GObject)
    end
  end
end

