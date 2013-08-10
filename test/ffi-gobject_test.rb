require 'gir_ffi_test_helper'

describe GObject do
  before do
    GirFFI.setup :Regress
  end

  describe "::signal_emit" do
    it "emits a signal" do
      a = 1
      o = Regress::TestSubObj.new
      callback = Proc.new { a = 2 }
      ::GObject::Lib.g_signal_connect_data o, "test", callback, nil, nil, 0
      GObject.signal_emit o, "test"
      assert_equal 2, a
    end

    it "handles return values" do
      s = Gio::SocketService.new

      argtypes = [:pointer, :pointer, :pointer, :pointer]
      callback = FFI::Function.new(:bool, argtypes) { |a,b,c,d| true }
      ::GObject::Lib.g_signal_connect_data s, "incoming", callback, nil, nil, 0
      rv = GObject.signal_emit s, "incoming"
      assert_equal true, rv.get_value
    end

    it "passes in extra arguments" do
      o = Regress::TestSubObj.new
      sb = Regress::TestSimpleBoxedA.new
      sb.some_int8 = 31
      sb.some_double = 2.42
      sb.some_enum = :value2
      b2 = nil

      argtypes = [:pointer, :pointer, :pointer]
      callback = FFI::Function.new(:void, argtypes) do |a,b,c|
        b2 = b
      end
      ::GObject::Lib.g_signal_connect_data o, "test-with-static-scope-arg", callback, nil, nil, 0
      GObject.signal_emit o, "test-with-static-scope-arg", sb

      sb2 = Regress::TestSimpleBoxedA.wrap b2
      assert sb.equals(sb2)
    end

    it "allows specifying signal detail" do
      a = 1
      o = Regress::TestSubObj.new

      callback = FFI::Function.new(:void, [:pointer, :pointer, :pointer]) { a = 2 }
      ::GObject::Lib.g_signal_connect_data o, "notify::detail", callback, nil, nil, 0

      GObject.signal_emit o, "notify::detail"

      a.must_equal 2
    end
  end

  describe "::signal_connect" do
    it "installs a signal handler" do
      a = 1
      o = Regress::TestSubObj.new
      GObject.signal_connect(o, "test") { a = 2 }
      GObject.signal_emit o, "test"
      assert_equal 2, a
    end

    it "passes user data to handler" do
      a = 1
      o = Regress::TestSubObj.new
      GObject.signal_connect(o, "test", 2) { |i, d| a = d }
      GObject.signal_emit o, "test"
      assert_equal 2, a
    end

    it "passes object to handler" do
      o = Regress::TestSubObj.new
      o2 = nil
      GObject.signal_connect(o, "test") { |i, d| o2 = i }
      GObject.signal_emit o, "test"
      assert_instance_of Regress::TestSubObj, o2
      assert_equal o.to_ptr, o2.to_ptr
    end

    it "does not allow connecting an invalid signal" do
      o = Regress::TestSubObj.new
      assert_raises RuntimeError do
        GObject.signal_connect(o, "not-really-a-signal") {}
      end
    end

    it "handles return values" do
      s = Gio::SocketService.new
      GObject.signal_connect(s, "incoming") { true }
      rv = GObject.signal_emit s, "incoming"
      assert_equal true, rv.get_value
    end

    it "requires a block" do
      o = Regress::TestSubObj.new
      assert_raises ArgumentError do
        GObject.signal_connect o, "test"
      end
    end

    it "allows specifying signal detail" do
      a = 1
      o = Regress::TestSubObj.new
      GObject.signal_connect(o, "notify::detail", 2) { |i, _, d| a = d }
      GObject.signal_emit o, "notify::detail"
      assert_equal 2, a
    end

    describe "connecting a signal with extra arguments" do
      before do
        @a = nil
        @b = 2

        o = Regress::TestSubObj.new
        sb = Regress::TestSimpleBoxedA.new
        sb.some_int = 23

        GObject.signal_connect(o, "test-with-static-scope-arg", 2) { |i, object, d|
          @a = d
          @b = object
        }
        GObject.signal_emit o, "test-with-static-scope-arg", sb
      end

      it "moves the user data argument" do
        assert_equal 2, @a
      end

      it "passes on the extra arguments" do
        assert_instance_of Regress::TestSimpleBoxedA, @b
        assert_equal 23, @b.some_int
      end
    end
  end
end
