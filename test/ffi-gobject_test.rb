# frozen_string_literal: true

require "gir_ffi_test_helper"

describe GObject do
  before do
    GirFFI.setup :Regress
  end

  describe "::signal_emit" do
    it "emits a signal" do
      a = 1
      o = Regress::TestSubObj.new
      prc = proc { a = 2 }
      callback = GObject::Callback.from prc
      GObject::Lib.g_signal_connect_data o, "test", callback, nil, nil, 0
      GObject.signal_emit o, "test"

      assert_equal 2, a
    end

    it "handles return values" do
      s = Gio::SocketService.new

      argtypes = [:pointer, :pointer, :pointer, :pointer]
      callback = FFI::Function.new(:bool, argtypes) { |_a, _b, _c, _d| true }
      GObject::Lib.g_signal_connect_data s, "incoming", callback, nil, nil, 0
      rv = GObject.signal_emit s, "incoming"

      assert rv
    end

    it "passes in extra arguments" do
      o = Regress::TestSubObj.new
      sb = Regress::TestSimpleBoxedA.new
      sb.some_int8 = 31
      sb.some_double = 2.42
      sb.some_enum = :value2
      b2 = nil

      argtypes = [:pointer, :pointer, :pointer]
      callback = FFI::Function.new(:void, argtypes) do |_a, b, _c|
        b2 = b
      end
      GObject::Lib.g_signal_connect_data(o, "test-with-static-scope-arg",
                                         callback, nil, nil, 0)
      GObject.signal_emit o, "test-with-static-scope-arg", sb

      sb2 = Regress::TestSimpleBoxedA.wrap b2

      assert sb.equals(sb2)
    end

    it "allows specifying signal detail" do
      a = 1
      o = Regress::TestSubObj.new

      callback = FFI::Function.new(:void, [:pointer, :pointer, :pointer]) { a = 2 }
      GObject::Lib.g_signal_connect_data o, "notify::detail", callback, nil, nil, 0

      GObject.signal_emit o, "notify::detail"

      _(a).must_equal 2
    end

    it "raises an error for signals with inout arguments" do
      skip_below "1.57.2"
      obj = Regress::TestObj.constructor
      obj.signal_connect "sig-with-inout-int" do |_obj, i, _ud|
        i + 1
      end

      _(proc { GObject.signal_emit obj, "sig-with-inout-int", 0 })
        .must_raise NotImplementedError
    end

    it "allows specifying the signal as a symbol" do
      a = 1
      o = Regress::TestSubObj.new
      GObject.signal_connect(o, "sig-with-uint64-prop") { |_, uint64, _| a = uint64 }
      GObject.signal_emit o, :sig_with_uint64_prop, 0xffff_ffff_ffff_ffff

      _(a).must_equal 0xffff_ffff_ffff_ffff
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
      GObject.signal_connect(o, "test", 2) { |_i, d| a = d }
      GObject.signal_emit o, "test"

      assert_equal 2, a
    end

    it "passes object to handler" do
      o = Regress::TestSubObj.new
      o2 = nil
      GObject.signal_connect(o, "test") { |i, _d| o2 = i }
      GObject.signal_emit o, "test"

      assert_instance_of Regress::TestSubObj, o2
      assert_equal o.to_ptr, o2.to_ptr
    end

    it "does not allow connecting an invalid signal" do
      o = Regress::TestSubObj.new

      _(proc { GObject.signal_connect(o, "not-really-a-signal") { nil } })
        .must_raise GirFFI::SignalNotFoundError
    end

    it "handles return values" do
      s = Gio::SocketService.new
      GObject.signal_connect(s, "incoming") { true }
      rv = GObject.signal_emit s, "incoming"

      assert rv
    end

    it "requires a block" do
      o = Regress::TestSubObj.new

      _(proc { GObject.signal_connect o, "test" }).must_raise ArgumentError
    end

    it "allows specifying signal detail" do
      a = 1
      o = Regress::TestSubObj.new
      GObject.signal_connect(o, "notify::detail", 2) { |_i, _, d| a = d }
      GObject.signal_emit o, "notify::detail"

      assert_equal 2, a
    end

    describe "connecting a signal with extra arguments" do
      before do
        @a = nil
        @b = 2

        obj = Regress::TestSubObj.new
        sb = Regress::TestSimpleBoxedA.new
        sb.some_int = 23

        GObject.signal_connect(obj, "test-with-static-scope-arg", 2) do |_i, o, u|
          @a = u
          @b = o
        end
        GObject.signal_emit obj, "test-with-static-scope-arg", sb
      end

      it "passes on the user data argument" do
        assert_equal 2, @a
      end

      it "passes on the extra arguments" do
        assert_instance_of Regress::TestSimpleBoxedA, @b
        assert_equal 23, @b.some_int
      end
    end

    it "allows specifying the signal as a symbol" do
      a = 1
      o = Regress::TestSubObj.new
      GObject.signal_connect(o, :sig_with_uint64_prop) { |_, uint64, _| a = uint64 }
      GObject.signal_emit o, "sig-with-uint64-prop", 0xffff_ffff_ffff_ffff

      _(a).must_equal 0xffff_ffff_ffff_ffff
    end
  end

  describe "::signal_connect_after" do
    it "installs a signal handler" do
      a = 1
      o = Regress::TestSubObj.new
      GObject.signal_connect_after(o, "test") { a = 2 }
      GObject.signal_emit o, "test"

      assert_equal 2, a
    end
  end
end
