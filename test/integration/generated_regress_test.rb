# frozen_string_literal: true

require 'gir_ffi_test_helper'

GirFFI.setup :Regress

class ConcreteDrawable < Regress::TestInheritDrawable
end

GirFFI.define_type ConcreteDrawable

# Tests generated methods and functions in the Regress namespace.
describe Regress do
  describe Regress::Lib do
    it 'extends FFI::Library' do
      _(Regress::Lib.singleton_class).must_be :include?, FFI::Library
    end
  end
  it 'has the constant ANNOTATION_CALCULATED_DEFINE' do
    _(Regress::ANNOTATION_CALCULATED_DEFINE).must_equal 100
  end
  it 'has the constant ANNOTATION_CALCULATED_LARGE' do
    skip 'Constant is marked with the wrong type'
    _(Regress::ANNOTATION_CALCULATED_LARGE).must_equal 10_000_000_000
  end
  it 'has the constant ANNOTATION_CALCULATED_LARGE_DIV' do
    _(Regress::ANNOTATION_CALCULATED_LARGE_DIV).must_equal 1_000_000
  end
  describe 'Regress::ATestError' do
    it 'has the member :code0' do
      _(Regress::ATestError[:code0]).must_equal 0
    end

    it 'has the member :code1' do
      _(Regress::ATestError[:code1]).must_equal 1
    end

    it 'has the member :code2' do
      _(Regress::ATestError[:code2]).must_equal 2
    end
  end

  describe 'Regress::AnAnonymousUnion' do
    let(:instance) { Regress::AnAnonymousUnion.new }

    it 'has a writable field x' do
      _(instance.x).must_equal 0
      instance.x = 42
      _(instance.x).must_equal 42
    end

    it 'has a writable field a' do
      skip 'Anonymous union fields are not exposed in the GIR data'
    end

    it 'has a writable field padding' do
      skip 'Anonymous union fields are not exposed in the GIR data'
    end
  end

  describe 'Regress::AnnotationBitfield' do
    it 'has the member :foo' do
      _(Regress::AnnotationBitfield[:foo]).must_equal 1
    end

    it 'has the member :bar' do
      _(Regress::AnnotationBitfield[:bar]).must_equal 2
    end
  end

  describe 'Regress::AnnotationFields' do
    let(:instance) { Regress::AnnotationFields.new }

    it 'has a writable field field1' do
      _(instance.field1).must_equal 0
      instance.field1 = 42
      _(instance.field1).must_equal 42
    end

    it 'has a writable field arr' do
      _(instance.arr).must_be_nil
      instance.arr = [1, 2, 3]
      # TODO: len should be set automatically
      instance.len = 3
      _(instance.arr.to_a).must_equal [1, 2, 3]
      _(instance.len).must_equal 3
    end

    it 'has a writable field len' do
      skip 'len should not be set independently'
    end
  end

  describe 'Regress::AnnotationObject' do
    let(:instance) { Regress::AnnotationObject.new }

    it 'has an attribute org.example.Test' do
      info = get_introspection_data('Regress', 'AnnotationObject')
      _(info.attribute('org.example.Test')).must_equal 'cows'
    end

    it 'has a working method #allow_none' do
      _(instance.allow_none('hello!')).must_be_nil
      _(instance.allow_none(nil)).must_be_nil
      _(instance.allow_none).must_be_nil
    end

    it 'has a working method #calleeowns' do
      result, object = instance.calleeowns
      _(result).must_equal 1
      _(object).must_be_nil
    end

    it 'has a working method #calleesowns' do
      result, toown1, toown2 = instance.calleesowns
      _(result).must_equal 1
      _(toown1).must_be_nil
      _(toown2).must_be_nil
    end

    it 'has a working method #compute_sum' do
      instance.compute_sum [1, 2, 3]
      pass
    end

    it 'has a working method #compute_sum_n' do
      instance.compute_sum_n [1, 2, 3]
      pass
    end

    it 'has a working method #compute_sum_nz' do
      instance.compute_sum_nz [1, 2, 3]
      pass
    end

    it 'has a working method #create_object' do
      result = instance.create_object
      _(result).must_equal instance
    end

    it 'has a working method #do_not_use' do
      # TODO: Handle deprecation
      _(instance.do_not_use).must_be_nil
    end

    it 'has a working method #extra_annos' do
      info = get_method_introspection_data('Regress', 'AnnotationObject', 'extra_annos')
      _(info.attribute('org.foobar')).must_equal 'testvalue'

      _(instance.extra_annos).must_be_nil
    end

    it 'has a working method #foreach' do
      a = 1
      instance.foreach { a += 1 }
      _(a).must_equal 1
    end

    it 'has a working method #get_hash' do
      result = instance.get_hash
      hash = result.to_hash
      _(hash['one']).must_equal instance
      _(hash['two']).must_equal instance
    end

    it 'has a working method #get_objects' do
      list = instance.get_objects
      _(list.to_a).must_equal [instance]
    end

    it 'has a working method #get_strings' do
      list = instance.get_strings
      _(list.to_a).must_equal %w(bar regress_annotation)
    end

    it 'has a working method #hidden_self' do
      _(instance.hidden_self).must_be_nil
    end

    it 'has a working method #in' do
      # TODO: Automatically convert to pointer argument
      ptr = FFI::MemoryPointer.new(:int, 1)
      ptr.put_int 0, 2342
      _(instance.in(ptr)).must_equal 2342
    end

    it 'has a working method #inout' do
      _(instance.inout(2342)).must_equal [2343, 2343]
    end

    it 'has a working method #inout2' do
      _(instance.inout2(2342)).must_equal [2343, 2343]
    end

    it 'has a working method #inout3' do
      _(instance.inout3(2342)).must_equal [2343, 2342]
    end

    it 'has a working method #method' do
      _(instance.method).must_equal 1
    end

    it 'has a working method #notrans' do
      _(instance.notrans).must_be_nil
    end

    it 'has a working method #out' do
      _(instance.out).must_equal [1, 2]
    end

    it 'has a working method #parse_args' do
      _(instance.parse_args(%w(one two)).to_a).must_equal %w(one two)
    end

    it 'has a working method #set_data' do
      # TODO: Explicitely allow or deny passing a string here.
      _(instance.set_data([1, 2, 3])).must_be_nil
    end

    it 'has a working method #set_data2' do
      _(instance.set_data2([1, -2, 3])).must_be_nil
    end

    it 'has a working method #set_data3' do
      _(instance.set_data3([1, 2, 3])).must_be_nil
    end

    it 'has a working method #string_out' do
      _(instance.string_out).must_equal [false, nil]
    end

    it 'has a working method #use_buffer' do
      skip 'Ingoing pointer argument conversion is not implemented yet'
      _(instance.use_buffer(FFI::MemoryPointer.new(:void, 1))).must_be_nil
    end

    it 'has a working method #watch_full' do
      instance.watch {}
    end

    it 'has a working method #with_voidp' do
      # NOTE: Anything implementing #to_ptr could be passed in here
      obj = Regress::AnnotationObject.new
      _(instance.with_voidp(obj)).must_be_nil
    end

    describe "its 'function-property' property" do
      it 'can be retrieved with #get_property' do
        _(instance.get_property('function-property')).must_be_nil
      end

      it 'can be retrieved with #function_property' do
        _(instance.function_property).must_be_nil
      end

      it 'can be set with #set_property' do
        instance.set_property('function-property', proc {})
        # AnnotationObject doesn't actually store stuff
        _(instance.function_property).must_be_nil
      end

      it 'can be set with #function_property=' do
        instance.function_property = proc {}
        # AnnotationObject doesn't actually store stuff
        _(instance.get_property('function-property')).must_be_nil
      end
    end

    describe "its 'string-property' property" do
      it 'can be retrieved with #get_property' do
        _(instance.get_property('string-property')).must_be_nil
      end

      it 'can be retrieved with #string_property' do
        _(instance.string_property).must_be_nil
      end

      it 'can be set with #set_property' do
        instance.set_property('string-property', 'hello 42')
        # AnnotationObject doesn't actually store stuff
        _(instance.string_property).must_be_nil
      end

      it 'can be set with #string_property=' do
        instance.string_property = 'hello 42'
        # AnnotationObject doesn't actually store stuff
        _(instance.get_property('string-property')).must_be_nil
      end
    end

    describe "its 'tab-property' property" do
      it 'can be retrieved with #get_property' do
        _(instance.get_property('tab-property')).must_be_nil
      end

      it 'can be retrieved with #tab_property' do
        _(instance.tab_property).must_be_nil
      end

      it 'can be set with #set_property' do
        instance.set_property('tab-property', 'hello 42')
        # AnnotationObject doesn't actually store stuff
        _(instance.tab_property).must_be_nil
      end

      it 'can be set with #tab_property=' do
        instance.tab_property = 'hello 42'
        # AnnotationObject doesn't actually store stuff
        _(instance.get_property('tab-property')).must_be_nil
      end
    end

    it "handles the 'attribute-signal' signal" do
      signal_info = get_signal_introspection_data('Regress',
                                                  'AnnotationObject',
                                                  'attribute-signal')
      argument_infos = signal_info.args
      _(argument_infos.first.attribute('some.annotation.foo1')).must_equal 'val1'
      _(argument_infos.last.attribute('some.annotation.foo2')).must_equal 'val2'

      result = nil
      instance.signal_connect 'attribute-signal' do |_obj, _arg1, _arg2, _user_data|
        # This signal uses a null marshaller, so the return value is never passed on.
        result = 'hello'
      end

      GObject.signal_emit instance, 'attribute-signal', 'foo', 'bar'
      _(result).must_equal 'hello'
    end

    it "handles the 'doc-empty-arg-parsing' signal" do
      test = nil
      instance.signal_connect 'doc-empty-arg-parsing' do |_obj, arg1, _user_data|
        test = arg1
      end

      result = GObject.signal_emit instance, 'doc-empty-arg-parsing', FFI::Pointer.new(123)
      _(result).must_be_nil
      _(test.address).must_equal 123
    end

    it "handles the 'list-signal' signal" do
      result = nil
      instance.signal_connect 'list-signal' do |_obj, list, _user_data|
        result = list
      end

      # TODO: Automatically convert to GLib::List
      GObject.signal_emit instance, 'list-signal', GLib::List.from(:utf8, %w(foo bar))
      _(result.to_a).must_equal %w(foo bar)
    end

    it "handles the 'string-signal' signal" do
      result = nil
      instance.signal_connect 'string-signal' do |_obj, string, _user_data|
        result = string
      end

      GObject.signal_emit instance, 'string-signal', 'foo'
      _(result).must_equal 'foo'
    end
  end

  describe 'Regress::AnnotationStruct' do
    let(:instance) { Regress::AnnotationStruct.new }

    it 'has a writable field objects' do
      _(instance.objects.to_a).must_equal [nil] * 10

      obj = Regress::AnnotationObject.new
      instance.objects = [nil] * 5 + [obj] + [nil] * 4
      _(instance.objects.to_a[5]).must_equal obj
    end
  end

  describe 'Regress::AnonymousUnionAndStruct' do
    let(:instance) { Regress::AnonymousUnionAndStruct.new }

    before { skip_below '1.49.1' }

    it 'has a writable field x' do
      instance.x = 42
      _(instance.x).must_equal 42
    end

    it 'has a writable field a' do
      skip 'Anonymous struct fields are not exposed in the GIR data'
    end

    it 'has a writable field b' do
      skip 'Anonymous struct fields are not exposed in the GIR data'
    end

    it 'has a writable field padding' do
      skip 'Anonymous union fields are not exposed in the GIR data'
    end
  end
  it 'has the constant BOOL_CONSTANT' do
    _(Regress::BOOL_CONSTANT).must_equal true
  end

  it 'has the constant DOUBLE_CONSTANT' do
    assert_equal 44.22, Regress::DOUBLE_CONSTANT
  end

  it 'has the constant FOO_DEFINE_SHOULD_BE_EXPOSED' do
    _(Regress::FOO_DEFINE_SHOULD_BE_EXPOSED).must_equal 'should be exposed'
  end

  it 'has the constant FOO_FLAGS_SECOND_AND_THIRD' do
    skip_below '1.55.2'
    _(Regress::FOO_FLAGS_SECOND_AND_THIRD).must_equal 6
  end

  it 'has the constant FOO_PIE_IS_TASTY' do
    _(Regress::FOO_PIE_IS_TASTY).must_equal 3.141590
  end

  it 'has the constant FOO_SUCCESS_INT' do
    _(Regress::FOO_SUCCESS_INT).must_equal 4408
  end

  describe 'Regress::FooASingle' do
    it 'has the member :foo_some_single_enum' do
      _(Regress::FooASingle[:foo_some_single_enum]).must_equal 0
    end
  end

  describe 'Regress::FooAddressType' do
    it 'has the member :invalid' do
      _(Regress::FooAddressType[:invalid]).must_equal 0
    end

    it 'has the member :ipv4' do
      _(Regress::FooAddressType[:ipv4]).must_equal 1
    end

    it 'has the member :ipv6' do
      _(Regress::FooAddressType[:ipv6]).must_equal 2
    end
  end

  describe 'Regress::FooBRect' do
    let(:instance) { Regress::FooBRect.wrap(Regress::FooBRect::Struct.new.to_ptr) }

    it 'has a writable field x' do
      _(instance.x).must_equal 0.0
      instance.x = 23.42
      _(instance.x).must_equal 23.42
    end

    it 'has a writable field y' do
      _(instance.y).must_equal 0.0
      instance.y = 23.42
      _(instance.y).must_equal 23.42
    end

    it 'creates an instance using #new' do
      skip 'This function is defined in the header but not implemented'
    end

    it 'has a working method #add' do
      skip 'This function is defined in the header but not implemented'
    end
  end

  describe 'Regress::FooBUnion' do
    let(:instance) { Regress::FooBUnion.wrap(Regress::FooBUnion::Struct.new.to_ptr) }

    it 'has a writable field type' do
      _(instance.type).must_equal 0
      instance.type = 42
      _(instance.type).must_equal 42
    end

    it 'has a writable field v' do
      _(instance.v).must_equal 0.0
      instance.v = 23.42
      _(instance.v).must_equal 23.42
    end

    it 'has a writable field rect' do
      _(instance.rect).must_be_nil
      rect = Regress::FooBRect.wrap(Regress::FooBRect::Struct.new.to_ptr)
      rect.x = 42
      rect.y = 23
      skip 'Cannot copy FooBRect structs'
      instance.rect = rect
      _(instance.rect.x).must_equal 42.0
      _(instance.rect.y).must_equal 23.0
    end

    it 'creates an instance using #new' do
      skip 'This function is defined in the header but not implemented'
    end

    it 'has a working method #get_contained_type' do
      skip 'This function is defined in the header but not implemented'
    end
  end

  describe 'Regress::FooBoxed' do
    let(:instance) { Regress::FooBoxed.new }

    it 'creates an instance using #new' do
      _(instance).must_be_instance_of Regress::FooBoxed
    end

    it 'has a working method #method' do
      _(instance.method).must_be_nil
    end
  end

  describe 'Regress::FooBuffer' do
    let(:instance) { Regress::FooBuffer.new }

    it 'creates an instance using #new' do
      _(instance).must_be_instance_of Regress::FooBuffer
    end

    it 'has a working method #some_method' do
      _(instance.some_method).must_be_nil
    end
  end

  describe 'Regress::FooDBusData' do
    let(:instance) { Regress::FooDBusData.new }

    it 'creates an instance using #new' do
      _(instance).must_be_instance_of Regress::FooDBusData
    end

    it 'has a working method #method' do
      skip 'This function is defined in the header but not implemented'
    end
  end

  describe 'Regress::FooEnumFullname' do
    it 'has the member :one' do
      _(Regress::FooEnumFullname[:one]).must_equal 1
    end

    it 'has the member :two' do
      _(Regress::FooEnumFullname[:two]).must_equal 2
    end

    it 'has the member :three' do
      _(Regress::FooEnumFullname[:three]).must_equal 3
    end
  end

  describe 'Regress::FooEnumNoType' do
    it 'has the member :un' do
      _(Regress::FooEnumNoType[:un]).must_equal 1
    end

    it 'has the member :deux' do
      _(Regress::FooEnumNoType[:deux]).must_equal 2
    end

    it 'has the member :trois' do
      _(Regress::FooEnumNoType[:trois]).must_equal 3
    end

    it 'has the member :neuf' do
      _(Regress::FooEnumNoType[:neuf]).must_equal 9
    end
  end

  describe 'Regress::FooEnumType' do
    it 'has the member :alpha' do
      _(Regress::FooEnumType[:alpha]).must_equal 0
    end

    it 'has the member :beta' do
      _(Regress::FooEnumType[:beta]).must_equal 1
    end

    it 'has the member :delta' do
      _(Regress::FooEnumType[:delta]).must_equal 2
    end

    it 'has a working function #method' do
      skip 'This function is defined in the header but not implemented'
    end

    it 'has a working function #returnv' do
      skip 'This function is defined in the header but not implemented'
    end
  end

  describe 'Regress::FooError' do
    it 'has the member :good' do
      _(Regress::FooError[:good]).must_equal 0
    end

    it 'has the member :bad' do
      _(Regress::FooError[:bad]).must_equal 1
    end

    it 'has the member :ugly' do
      _(Regress::FooError[:ugly]).must_equal 2
    end

    it 'has a working function #quark' do
      quark = Regress::FooError.quark
      _(GLib.quark_to_string(quark)).must_equal 'regress_foo-error-quark'
    end
  end

  describe 'Regress::FooEvent' do
    let(:instance) { Regress::FooEvent.new }

    it 'has a writable field type' do
      _(instance.type).must_equal 0
      instance.type = 23
      _(instance.type).must_equal 23
    end

    it 'has a writable field any' do
      _(instance.any.send_event).must_equal 0
      any = Regress::FooEventAny.new
      any.send_event = 42
      instance.any = any
      _(instance.any.send_event).must_equal 42
    end

    it 'has a writable field expose' do
      _(instance.expose.send_event).must_equal 0
      _(instance.expose.count).must_equal 0
      expose = Regress::FooEventExpose.new
      expose.send_event = 23
      expose.count = 14
      instance.expose = expose
      _(instance.expose.send_event).must_equal 23
      _(instance.expose.count).must_equal 14
    end
  end

  describe 'Regress::FooEventAny' do
    let(:instance) { Regress::FooEventAny.new }

    it 'has a writable field send_event' do
      _(instance.send_event).must_equal 0
      instance.send_event = 23
      _(instance.send_event).must_equal 23
    end
  end

  describe 'Regress::FooEventExpose' do
    let(:instance) { Regress::FooEventExpose.new }

    it 'has a writable field send_event' do
      _(instance.send_event).must_equal 0
      instance.send_event = 23
      _(instance.send_event).must_equal 23
    end

    it 'has a writable field count' do
      _(instance.count).must_equal 0
      instance.count = 42
      _(instance.count).must_equal 42
    end
  end

  describe 'Regress::FooFlagsNoType' do
    it 'has the member :ett' do
      _(Regress::FooFlagsNoType[:ett]).must_equal 1
    end

    it 'has the member :tva' do
      _(Regress::FooFlagsNoType[:tva]).must_equal 2
    end

    it 'has the member :fyra' do
      _(Regress::FooFlagsNoType[:fyra]).must_equal 4
    end
  end

  describe 'Regress::FooFlagsType' do
    it 'has the member :first' do
      _(Regress::FooFlagsType[:first]).must_equal 1
    end

    it 'has the member :second' do
      _(Regress::FooFlagsType[:second]).must_equal 2
    end

    it 'has the member :third' do
      _(Regress::FooFlagsType[:third]).must_equal 4
    end
  end

  describe 'Regress::FooForeignStruct' do
    let(:instance) { Regress::FooForeignStruct.new }

    it 'has a writable field regress_foo' do
      _(instance.regress_foo).must_equal 0
      instance.regress_foo = 143
      _(instance.regress_foo).must_equal 143
    end

    it 'creates an instance using #new' do
      _(instance).must_be_instance_of Regress::FooForeignStruct
    end

    it 'has a working method #copy' do
      instance.regress_foo = 585
      result = instance.copy
      instance.regress_foo = 0
      _(result.regress_foo).must_equal 585
    end
  end

  describe 'Regress::FooInterface' do
    it 'has a working function #static_method' do
      _(Regress::FooInterface.static_method(42)).must_be_nil
    end

    it 'has a working method #do_regress_foo' do
      instance = Regress::FooObject.new
      _(instance).must_be_kind_of Regress::FooInterface
      _(instance.do_regress_foo(42)).must_be_nil
    end
  end

  describe 'Regress::FooObject' do
    let(:instance) { Regress::FooObject.new }

    it 'creates an instance using #new' do
      _(instance).must_be_instance_of Regress::FooObject
    end

    it 'creates an instance using #new_as_super' do
      other_instance = Regress::FooObject.new_as_super
      _(other_instance).must_be_instance_of Regress::FooObject
    end

    it 'has a working function #a_global_method' do
      skip 'This function is defined in the header but not implemented'
    end

    it 'has a working function #get_default' do
      _(Regress::FooObject.get_default).must_be_nil
    end

    it 'has a working function #static_meth' do
      skip 'This function is defined in the header but not implemented'
    end

    it 'has a working method #append_new_stack_layer' do
      _(instance.append_new_stack_layer(42)).must_be_nil
    end

    it 'has a working method #dup_name' do
      _(instance.dup_name).must_equal 'regress_foo'
    end

    it 'has a working method #external_type' do
      result = instance.external_type
      _(result).must_be_nil
    end

    it 'has a working method #get_name' do
      _(instance.get_name).must_equal 'regress_foo'
    end

    it 'has a working method #handle_glyph' do
      skip 'This function is defined in the header but not implemented'
    end

    it 'has a working method #is_it_time_yet' do
      _(instance.is_it_time_yet(Time.now.to_i)).must_be_nil
    end

    it 'has a working method #read' do
      _(instance.read(12, 13)).must_be_nil
    end

    it 'has a working method #various' do
      skip 'This function is defined in the header but not implemented'
    end

    it 'has a working method #virtual_method' do
      skip 'This function is defined in the header but not implemented'
    end

    describe "its 'string' property" do
      it 'can be retrieved with #get_property' do
        _(instance.get_property('string')).must_be_nil
      end

      it 'can be retrieved with #string' do
        _(instance.string).must_be_nil
      end

      it 'can be set with #set_property' do
        instance.set_property 'string', 'hello 42'
        # FooObject doesn't actually store stuff
        _(instance.string).must_be_nil
        _(instance.get_property('string')).must_be_nil
      end

      it 'can be set with #string=' do
        instance.string = 'hello 42'
        # FooObject doesn't actually store stuff
        _(instance.string).must_be_nil
        _(instance.get_property('string')).must_be_nil
      end
    end

    it "handles the 'signal' signal" do
      instance.signal_connect 'signal' do
        'hello'
      end

      result = GObject.signal_emit instance, 'signal'
      _(result).must_equal 'hello'
    end
  end

  describe 'Regress::FooOtherObject' do
    it 'is derived from GObject::Object' do
      _(Regress::FooOtherObject.superclass).must_equal GObject::Object
    end
  end

  describe 'Regress::FooRectangle' do
    let(:instance) { Regress::FooRectangle.new }

    it 'has a writable field x' do
      _(instance.x).must_equal 0
      instance.x = 23
      _(instance.x).must_equal 23
    end

    it 'has a writable field y' do
      _(instance.y).must_equal 0
      instance.y = 23
      _(instance.y).must_equal 23
    end

    it 'has a writable field width' do
      _(instance.width).must_equal 0
      instance.width = 23
      _(instance.width).must_equal 23
    end

    it 'has a writable field height' do
      _(instance.height).must_equal 0
      instance.height = 23
      _(instance.height).must_equal 23
    end

    it 'has a working method #add' do
      skip 'Not implemented yet'
      other_instance = Regress::FooRectangle.new
      instance.add other_instance
    end
  end

  describe 'Regress::FooStackLayer' do
    it 'has the member :desktop' do
      _(Regress::FooStackLayer[:desktop]).must_equal 0
    end

    it 'has the member :bottom' do
      _(Regress::FooStackLayer[:bottom]).must_equal 1
    end

    it 'has the member :normal' do
      _(Regress::FooStackLayer[:normal]).must_equal 2
    end

    it 'has the member :top' do
      _(Regress::FooStackLayer[:top]).must_equal 4
    end

    it 'has the member :dock' do
      _(Regress::FooStackLayer[:dock]).must_equal 4
    end

    it 'has the member :fullscreen' do
      _(Regress::FooStackLayer[:fullscreen]).must_equal 5
    end

    it 'has the member :focused_window' do
      _(Regress::FooStackLayer[:focused_window]).must_equal 6
    end

    it 'has the member :override_redirect' do
      _(Regress::FooStackLayer[:override_redirect]).must_equal 7
    end

    it 'has the member :last' do
      _(Regress::FooStackLayer[:last]).must_equal 8
    end
  end

  describe 'Regress::FooStruct' do
    let(:instance) { Regress::FooStruct.new }

    it 'blocks access to the hidden struct field priv' do
      _(proc { instance.priv = nil }).must_raise NoMethodError
      _(proc { instance.priv }).must_raise NoMethodError
    end

    it 'has a writable field member' do
      _(instance.member).must_equal 0
      instance.member = 23
      _(instance.member).must_equal 23
    end
  end

  describe 'Regress::FooSubInterface' do
    let(:derived_klass) do
      Object.const_set("DerivedClass#{Sequence.next}",
                       Class.new(Regress::FooObject))
    end

    def make_derived_instance
      derived_klass.send :include, Regress::FooSubInterface
      GirFFI.define_type derived_klass do |info|
        yield info if block_given?
      end
      derived_klass.new
    end

    it 'has a working method #do_bar' do
      result = nil
      instance = make_derived_instance do |info|
        info.install_vfunc_implementation :do_bar, proc { |obj| result = obj.get_name }
      end
      instance.do_bar
      _(result).must_equal 'regress_foo'
    end

    it 'has a working method #do_baz' do
      a = nil
      instance = make_derived_instance do |info|
        # TODO: Do not pass callback again in user_data if destroy notifier is absent
        info.install_vfunc_implementation :do_baz,
                                          proc { |obj, callback, _user_data| callback.call; a = obj.get_name }
      end
      b = nil
      instance.do_baz { b = 'hello' }
      _(a).must_equal 'regress_foo'
      _(b).must_equal 'hello'
    end

    it "handles the 'destroy-event' signal" do
      a = nil
      instance = make_derived_instance
      instance.signal_connect 'destroy-event' do
        a = 'hello'
      end
      GObject.signal_emit instance, 'destroy-event'
      _(a).must_equal 'hello'
    end
  end

  describe 'Regress::FooSubobject' do
    it 'creates an instance using #new' do
      skip 'This function is defined in the header but not implemented'
    end
  end

  describe 'Regress::FooThingWithArray' do
    let(:instance) { Regress::FooThingWithArray.new }

    it 'has a writable field x' do
      _(instance.x).must_equal 0
      instance.x = 23
      _(instance.x).must_equal 23
    end

    it 'has a writable field y' do
      _(instance.y).must_equal 0
      instance.y = 23
      _(instance.y).must_equal 23
    end

    it 'has a writable field lines' do
      _(instance.lines).must_be :==, [0] * 80
      instance.lines = (1..80).to_a
      _(instance.lines).must_be :==, (1..80).to_a
    end

    it 'has a writable field data' do
      _(instance.data).must_equal FFI::Pointer::NULL
      instance.data = FFI::Pointer.new(23)
      _(instance.data).must_equal FFI::Pointer.new(23)
    end
  end

  describe 'Regress::FooUnion' do
    let(:instance) { Regress::FooUnion.new }

    it 'has a writable field regress_foo' do
      _(instance.regress_foo).must_equal 0
      instance.regress_foo = 23
      _(instance.regress_foo).must_equal 23
    end
  end

  describe 'Regress::FooUtilityStruct' do
    let(:instance) { Regress::FooUtilityStruct.new }

    it 'has a writable field bar' do
      struct = Utility::Struct.new
      struct.field = 23

      _(instance.bar.field).must_equal 0
      instance.bar = struct
      _(instance.bar.field).must_equal 23
    end
  end

  it 'has the constant GI_SCANNER_ELSE' do
    _(Regress::GI_SCANNER_ELSE).must_equal 3
  end

  it 'has the constant GI_SCANNER_IFDEF' do
    _(Regress::GI_SCANNER_IFDEF).must_equal 3
  end

  it 'has the constant GUINT64_CONSTANT' do
    _(Regress::GUINT64_CONSTANT).must_equal 18_446_744_073_709_551_615
  end

  it 'has the constant GUINT64_CONSTANTA' do
    _(Regress::GUINT64_CONSTANTA).must_equal 18_446_744_073_709_551_615
  end

  it 'has the constant G_GINT64_CONSTANT' do
    _(Regress::G_GINT64_CONSTANT).must_equal 1000
  end

  it 'has the constant INT_CONSTANT' do
    assert_equal 4422, Regress::INT_CONSTANT
  end

  it 'has the constant LONG_STRING_CONSTANT' do
    _(Regress::LONG_STRING_CONSTANT).must_equal %w(TYPE VALUE ENCODING CHARSET
                                                   LANGUAGE DOM INTL POSTAL PARCEL
                                                   HOME WORK PREF VOICE FAX MSG
                                                   CELL PAGER BBS MODEM CAR ISDN
                                                   VIDEO AOL APPLELINK ATTMAIL CIS
                                                   EWORLD INTERNET IBMMAIL MCIMAIL
                                                   POWERSHARE PRODIGY TLX X400 GIF
                                                   CGM WMF BMP MET PMB DIB PICT
                                                   TIFF PDF PS JPEG QTIME MPEG
                                                   MPEG2 AVI WAVE AIFF PCM X509
                                                   PGP).join(',')
  end

  describe 'Regress::LikeGnomeKeyringPasswordSchema' do
    it 'creates an instance using #new' do
      obj = Regress::LikeGnomeKeyringPasswordSchema.new
      _(obj).must_be_instance_of Regress::LikeGnomeKeyringPasswordSchema
    end

    let(:instance) { Regress::LikeGnomeKeyringPasswordSchema.new }

    it 'has a writable field dummy' do
      _(instance.dummy).must_equal 0
      instance.dummy = 42
      _(instance.dummy).must_equal 42
    end

    it 'has a writable field attributes' do
      skip 'Introspection data cannot deal with type of this field yet'
    end

    it 'has a writable field dummy2' do
      _(instance.dummy2).must_equal 0.0
      instance.dummy2 = 42.42
      _(instance.dummy2).must_equal 42.42
    end
  end

  describe 'Regress::LikeXklConfigItem' do
    let(:instance) { Regress::LikeXklConfigItem.new }
    let(:name_array) { 'foo'.bytes.to_a + [0] * 29 }

    it 'has a writable field name' do
      # TODO: Should an array of gint8 be more string-like?
      _(instance.name.to_a).must_equal [0] * 32
      instance.name = name_array
      _(instance.name.to_a).must_equal name_array
    end

    it 'has a working method #set_name' do
      instance.set_name 'foo'
      _(instance.name.to_a).must_equal name_array
    end
  end

  it 'has the constant MAXUINT64' do
    _(Regress::MAXUINT64).must_equal 0xffff_ffff_ffff_ffff
  end

  it 'has the constant MININT64' do
    _(Regress::MININT64).must_equal(-0x8000_0000_0000_0000)
  end

  it 'has the constant Mixed_Case_Constant' do
    assert_equal 4423, Regress::Mixed_Case_Constant
  end

  it 'has the constant NEGATIVE_INT_CONSTANT' do
    _(Regress::NEGATIVE_INT_CONSTANT).must_equal(-42)
  end

  it 'has the constant STRING_CONSTANT' do
    assert_equal 'Some String', Regress::STRING_CONSTANT
  end

  describe 'Regress::TestABCError' do
    it 'has the member :code1' do
      _(Regress::TestABCError[:code1]).must_equal 1
    end

    it 'has the member :code2' do
      _(Regress::TestABCError[:code2]).must_equal 2
    end

    it 'has the member :code3' do
      _(Regress::TestABCError[:code3]).must_equal 3
    end

    it 'has a working function #quark' do
      quark = Regress::TestABCError.quark
      _(GLib.quark_to_string(quark)).must_equal 'regress-test-abc-error'
    end
  end

  describe 'Regress::TestBoxed' do
    let(:instance) { Regress::TestBoxed.new_alternative_constructor1 123 }

    it 'has a writable field some_int8' do
      _(instance.some_int8).must_equal 123
      instance.some_int8 = -43
      _(instance.some_int8).must_equal(-43)
    end

    it 'has a writable field nested_a' do
      _(instance.nested_a.some_int).must_equal 0
      nested = Regress::TestSimpleBoxedA.new
      nested.some_int = 12_345
      instance.nested_a = nested
      _(instance.nested_a.some_int).must_equal 12_345
    end

    it 'blocks access to the hidden struct field priv' do
      _(proc { instance.priv = nil }).must_raise NoMethodError
      _(proc { instance.priv }).must_raise NoMethodError
    end

    it 'creates an instance using #new' do
      tb = Regress::TestBoxed.new
      assert_instance_of Regress::TestBoxed, tb
    end

    it 'creates an instance using #new_alternative_constructor1' do
      tb = Regress::TestBoxed.new_alternative_constructor1 1
      assert_instance_of Regress::TestBoxed, tb
      assert_equal 1, tb.some_int8
    end

    it 'creates an instance using #new_alternative_constructor2' do
      tb = Regress::TestBoxed.new_alternative_constructor2 1, 2
      assert_instance_of Regress::TestBoxed, tb
      assert_equal 1 + 2, tb.some_int8
    end

    it 'creates an instance using #new_alternative_constructor3' do
      tb = Regress::TestBoxed.new_alternative_constructor3 '54'
      assert_instance_of Regress::TestBoxed, tb
      assert_equal 54, tb.some_int8
    end

    it 'has non-zero positive result for #gtype' do
      _(Regress::TestBoxed.gtype).must_be :>, 0
    end

    it 'has a working method #_not_a_method' do
      # NOTE: This method is marked as moved, but this is not exposed in the typelib
      instance._not_a_method
      pass
    end

    it 'has a working method #copy' do
      tb2 = instance.copy
      assert_instance_of Regress::TestBoxed, tb2
      assert_equal 123, tb2.some_int8
      instance.some_int8 = 89
      assert_equal 123, tb2.some_int8
    end

    it 'has a working method #equals' do
      tb2 = Regress::TestBoxed.new_alternative_constructor2 120, 3
      assert_equal true, instance.equals(tb2)
    end
  end

  describe 'Regress::TestBoxedB' do
    let(:instance) { Regress::TestBoxedB.new 8, 42 }

    it 'has a writable field some_int8' do
      _(instance.some_int8).must_equal 8
      instance.some_int8 = -43
      _(instance.some_int8).must_equal(-43)
    end

    it 'has a writable field some_long' do
      _(instance.some_long).must_equal 42
      instance.some_long = -4342
      _(instance.some_long).must_equal(-4342)
    end

    it 'creates an instance using #new' do
      tb = Regress::TestBoxedB.new 8, 42
      assert_instance_of Regress::TestBoxedB, tb
    end

    it 'has a working method #copy' do
      cp = instance.copy
      _(cp).must_be_instance_of Regress::TestBoxedB
      _(cp.some_int8).must_equal 8
      _(cp.some_long).must_equal 42
      instance.some_int8 = 2
      _(cp.some_int8).must_equal 8
    end
  end

  describe 'Regress::TestBoxedC' do
    let(:instance) { Regress::TestBoxedC.new }

    it 'has a writable field refcount' do
      _(instance.refcount).must_equal 1
      instance.refcount = 2
      _(instance.refcount).must_equal 2
    end

    it 'has a writable field another_thing' do
      _(instance.another_thing).must_equal 42
      instance.another_thing = 4342
      _(instance.another_thing).must_equal 4342
    end

    it 'creates an instance using #new' do
      tb = Regress::TestBoxedC.new
      assert_instance_of Regress::TestBoxedC, tb
    end
  end

  describe 'Regress::TestBoxedD' do
    let(:instance) { Regress::TestBoxedD.new 'foo', 42 }

    it 'creates an instance using #new' do
      _(instance).must_be_instance_of Regress::TestBoxedD
    end

    it 'has a working method #copy' do
      copy = instance.copy
      _(copy).must_be_instance_of Regress::TestBoxedD
      _(instance.get_magic).must_equal copy.get_magic
      _(instance).wont_equal copy
    end

    it 'has a working method #free' do
      skip "#free is used internally and shouldn't be exposed"
      instance.free
      pass
    end

    it 'has a working method #get_magic' do
      _(instance.get_magic).must_equal 'foo'.length + 42
    end
  end

  describe 'Regress::TestDEFError' do
    it 'has the member :code0' do
      _(Regress::TestDEFError[:code0]).must_equal 0
    end

    it 'has the member :code1' do
      _(Regress::TestDEFError[:code1]).must_equal 1
    end

    it 'has the member :code2' do
      _(Regress::TestDEFError[:code2]).must_equal 2
    end
  end

  describe 'Regress::TestEnum' do
    it 'has the member :value1' do
      _(Regress::TestEnum[:value1]).must_equal 0
    end

    it 'has the member :value2' do
      _(Regress::TestEnum[:value2]).must_equal 1
    end

    it 'has the member :value3' do
      _(Regress::TestEnum[:value3]).must_equal(-1)
    end

    it 'has the member :value4' do
      _(Regress::TestEnum[:value4]).must_equal 48
    end

    it 'has the member :value5' do
      skip_below '1.55.2'
      _(Regress::TestEnum[:value5]).must_equal 49
    end

    it 'has a working function #param' do
      _(Regress::TestEnum.param(:value1)).must_equal('value1')
      _(Regress::TestEnum.param(:value2)).must_equal('value2')
      _(Regress::TestEnum.param(:value3)).must_equal('value3')
      _(Regress::TestEnum.param(:value4)).must_equal('value4')
      _(Regress::TestEnum.param(0)).must_equal('value1')
      _(Regress::TestEnum.param(1)).must_equal('value2')
      _(Regress::TestEnum.param(-1)).must_equal('value3')
      _(Regress::TestEnum.param(48)).must_equal('value4')
    end
  end

  describe 'Regress::TestEnumNoGEnum' do
    it 'has the member :evalue1' do
      _(Regress::TestEnumNoGEnum[:evalue1]).must_equal 0
    end

    it 'has the member :evalue2' do
      _(Regress::TestEnumNoGEnum[:evalue2]).must_equal 42
    end

    it 'has the member :evalue3' do
      _(Regress::TestEnumNoGEnum[:evalue3]).must_equal 48
    end
  end

  describe 'Regress::TestEnumUnsigned' do
    it 'has the member :value1' do
      _(Regress::TestEnumUnsigned[:value1]).must_equal 1
    end

    # NOTE In c, the positive and negative values are not distinguished
    it 'has the member :value2' do
      _(Regress::TestEnumUnsigned[:value2]).must_equal(-2_147_483_648)
    end
  end

  describe 'Regress::TestError' do
    it 'has the member :code1' do
      _(Regress::TestError[:code1]).must_equal 1
    end

    it 'has the member :code2' do
      _(Regress::TestError[:code2]).must_equal 2
    end

    it 'has the member :code3' do
      _(Regress::TestError[:code3]).must_equal 3
    end

    it 'has a working function #quark' do
      quark = Regress::TestError.quark
      _(GLib.quark_to_string(quark)).must_equal 'regress-test-error'
    end
  end

  describe 'Regress::TestFlags' do
    it 'has the member :flag1' do
      assert_equal 1, Regress::TestFlags[:flag1]
    end
    it 'has the member :flag2' do
      assert_equal 2, Regress::TestFlags[:flag2]
    end
    it 'has the member :flag3' do
      assert_equal 4, Regress::TestFlags[:flag3]
    end
  end

  describe 'Regress::TestFloating' do
    it 'creates an instance using #new' do
      o = Regress::TestFloating.new
      _(o).must_be_instance_of Regress::TestFloating
    end

    describe 'an instance' do
      before do
        @o = Regress::TestFloating.new
      end

      it 'has a reference count of 1' do
        assert_equal 1, object_ref_count(@o)
      end

      it 'has been sunk' do
        _(@o).wont_be :floating?
      end
    end
  end

  describe 'Regress::TestFundamentalObject' do
    it 'does not have GObject::Object as an ancestor' do
      refute(Regress::TestFundamentalObject < GObject::Object)
    end

    it 'cannot be instantiated' do
      _(proc { Regress::TestFundamentalObject.new }).must_raise NoMethodError
    end

    let(:derived_instance) { Regress::TestFundamentalSubObject.new 'foo' }
    let(:base_struct) { Regress::TestFundamentalObject::Struct.new derived_instance.to_ptr }

    it 'has a working method #ref' do
      _(base_struct[:refcount]).must_equal 1
      derived_instance.ref
      _(base_struct[:refcount]).must_equal 2
    end

    it 'has a working method #unref' do
      _(base_struct[:refcount]).must_equal 1
      derived_instance.unref
      _(base_struct[:refcount]).must_equal 0
    end
  end

  describe 'Regress::TestFundamentalSubObject' do
    it 'creates an instance using #new' do
      obj = Regress::TestFundamentalSubObject.new 'foo'
      _(obj).must_be_instance_of Regress::TestFundamentalSubObject
    end

    let(:instance) { Regress::TestFundamentalSubObject.new 'foo' }

    it 'is a subclass of TestFundamentalObject' do
      assert_kind_of Regress::TestFundamentalObject, instance
    end

    it 'has a field :data storing the constructor parameter' do
      assert_equal 'foo', instance.struct[:data].to_utf8
    end
  end

  describe 'Regress::TestInheritDrawable' do
    it 'cannot be instantiated' do
      _(proc { Regress::TestInheritDrawable.new }).must_raise NoMethodError
    end

    let(:derived_instance) { ConcreteDrawable.new }

    it 'has a working method #do_foo' do
      derived_instance.do_foo 42
      pass
    end

    it 'has a working method #do_foo_maybe_throw' do
      derived_instance.do_foo_maybe_throw 42
      _(proc { derived_instance.do_foo_maybe_throw 41 }).must_raise GirFFI::GLibError
    end

    it 'has a working method #get_origin' do
      _(derived_instance.get_origin).must_equal [0, 0]
    end

    it 'has a working method #get_size' do
      _(derived_instance.get_size).must_equal [42, 42]
    end
  end

  describe 'Regress::TestInheritPixmapObjectClass' do
    it 'has a writable field parent_class' do
      skip 'This is a class struct without defined class'
    end
  end

  describe 'Regress::TestInterface' do
    let(:derived_klass) do
      klass = Object.const_set("DerivedClass#{Sequence.next}",
                               Class.new(Regress::FooObject))
      klass.send :include, Regress::TestInterface
      GirFFI.define_type klass do |info|
        info.install_property GObject.param_spec_int('number', 'Number', 'Number',
                                                     0, 10, 0,
                                                     readwrite: true, construct: true)
      end
      klass
    end

    it 'is a module' do
      assert_instance_of Module, Regress::TestInterface
    end

    it 'extends InterfaceBase' do
      _(Regress::TestInterface.singleton_class).must_include GirFFI::InterfaceBase
    end

    it 'has non-zero positive result for #gtype' do
      _(Regress::TestInterface.gtype).must_be :>, 0
    end

    it 'has a working method #emit_signal' do
      skip_below '1.57.2'
      a = nil
      instance = derived_klass.new
      GObject.signal_connect instance, 'interface-signal' do
        a = 'hello'
      end
      instance.emit_signal
      _(a).must_equal 'hello'
    end

    describe "its 'number' property" do
      before { skip_below '1.59.1' }

      let(:instance) { derived_klass.new }

      it 'can be retrieved with #get_property' do
        _(instance.get_property('number')).must_equal 0
      end

      it 'can be retrieved with #number' do
        _(instance.number).must_equal 0
      end

      it 'can be set with #set_property' do
        instance.set_property('number', 10)
        _(instance.get_property('number')).must_equal 10
      end

      it 'can be set with #number=' do
        instance.number = 4

        _(instance.number).must_equal 4
        _(instance.get_property('number')).must_equal 4
      end
    end
    it "handles the 'interface-signal' signal" do
      skip_below '1.57.2'
      skip 'Not implemented yet'
      a = nil
      instance = derived_klass.new
      GObject.signal_connect instance, 'interface-signal' do
        a = 'hello'
      end
      GObject.signal_emit instance, 'interface-signal'
      _(a).must_equal 'hello'
    end
  end

  describe 'Regress::TestObj' do
    it 'creates an instance using #constructor' do
      obj = Regress::TestObj.constructor
      _(obj).must_be_instance_of Regress::TestObj
    end

    it 'creates an instance using #new' do
      o1 = Regress::TestObj.constructor
      o2 = Regress::TestObj.new o1
      _(o2).must_be_instance_of Regress::TestObj
    end

    it 'creates an instance using #new_callback' do
      a = 1
      o = Regress::TestObj.new_callback { a = 2 }
      assert_instance_of Regress::TestObj, o
      _(a).must_equal 2

      # Regress::TestObj.new_callback adds a callback to the list of notified
      # callbacks. Thaw the callbacks to make sure the list is cleared for
      # later tests.
      result = Regress.test_callback_thaw_notifications
      _(result).must_equal 2
    end

    it 'creates an instance using #new_from_file' do
      o = Regress::TestObj.new_from_file('foo')
      assert_instance_of Regress::TestObj, o
    end

    it 'has a working function #null_out' do
      obj = Regress::TestObj.null_out
      _(obj).must_be_nil
    end

    it 'has a working function #static_method' do
      rv = Regress::TestObj.static_method 623
      assert_equal 623.0, rv
    end

    it 'has a working function #static_method_callback' do
      a = 1
      Regress::TestObj.static_method_callback { a = 2 }
      assert_equal 2, a
    end

    let(:instance) { Regress::TestObj.new_from_file('foo') }

    describe 'its gtype' do
      it 'can be found through gtype and GObject.type_from_instance' do
        gtype = Regress::TestObj.gtype
        r = GObject.type_from_instance instance
        assert_equal gtype, r
      end
    end

    it 'has a reference count of 1' do
      assert_equal 1, object_ref_count(instance)
    end

    it 'does not float' do
      _(instance).wont_be :floating?
    end

    it 'has a working method #matrix' do
      _(instance.matrix('bar')).must_equal 42
    end

    it 'has a working method #do_matrix' do
      _(instance.do_matrix('bar')).must_equal 42
    end

    it 'has a working method #emit_sig_with_array_len_prop' do
      skip_below '1.47.92'
      array = nil
      instance.signal_connect 'sig-with-array-len-prop' do |_obj, ary|
        array = ary.to_a
      end
      instance.emit_sig_with_array_len_prop
      _(array.to_a).must_equal [0, 1, 2, 3, 4]
    end

    it 'has a working method #emit_sig_with_error' do
      skip_below '1.61.1'
      skip 'Not implemented yet'
      error = nil
      instance.signal_connect 'sig-with-gerror' do |_obj, err|
        error = err
      end
      instance.emit_sig_with_error
      _(error).must_be_instance_of GLib::Error
    end

    it 'has a working method #emit_sig_with_foreign_struct' do
      has_fired = false
      instance.signal_connect 'sig-with-foreign-struct' do |_obj, cr|
        has_fired = true
        _(cr).must_be_instance_of Cairo::Context
      end
      instance.emit_sig_with_foreign_struct
      assert has_fired
    end

    it 'has a working method #emit_sig_with_inout_int' do
      skip_below '1.57.2'
      instance.signal_connect 'sig-with-inout-int' do |_obj, i, _ud|
        i + 1
      end
      instance.emit_sig_with_inout_int
    end

    it 'has a working method #emit_sig_with_int64' do
      instance.signal_connect 'sig-with-int64-prop' do |_obj, i, _ud|
        i
      end
      instance.emit_sig_with_int64
    end

    it 'has a working method #emit_sig_with_null_error' do
      skip_below '1.61.1'
      skip 'Not implemented yet'
      error = nil
      instance.signal_connect 'sig-with-gerror' do |_obj, err|
        error = err
      end
      instance.emit_sig_with_null_error
      _(error).must_be_nil
    end

    it 'has a working method #emit_sig_with_obj' do
      has_fired = false
      instance.signal_connect 'sig-with-obj' do |_it, obj|
        has_fired = true
        _(obj.int).must_equal 3
      end
      instance.emit_sig_with_obj
      assert has_fired
    end

    it 'has a working method #emit_sig_with_uint64' do
      instance.signal_connect 'sig-with-uint64-prop' do |_obj, i, _ud|
        i
      end
      instance.emit_sig_with_uint64
    end

    it 'has a working method #forced_method' do
      instance.forced_method
      pass
    end

    it 'has a working method #instance_method' do
      rv = instance.instance_method
      assert_equal(-1, rv)
    end

    it 'has a working method #instance_method_callback' do
      a = 1
      instance.instance_method_callback { a = 2 }
      assert_equal 2, a
    end

    it 'has a working method #instance_method_full' do
      _(object_ref_count(instance)).must_equal 1
      instance.instance_method_full
      _(object_ref_count(instance)).must_equal 1
    end

    it 'has a working method #name_conflict' do
      skip_below '1.53.4'
      _(instance.name_conflict).must_be_nil
    end

    it 'has a working method #not_nullable_element_typed_gpointer_in' do
      skip_below '1.47.92'
      instance.not_nullable_element_typed_gpointer_in [1, 2, 3]
      # TODO: Make method raise when passed nil
    end

    it 'has a working method #not_nullable_typed_gpointer_in' do
      skip_below '1.47.92'
      obj = Regress::TestObj.new_from_file('bar')
      instance.not_nullable_typed_gpointer_in obj
      # TODO: Make method raise when passed nil
    end

    it 'has a working method #set_bare' do
      obj = Regress::TestObj.new_from_file('bar')
      instance.set_bare obj
      _(instance.bare).must_equal obj
    end

    it 'has a working method #skip_inout_param' do
      a = 1
      c = 2.0
      num1 = 3
      num2 = 4
      result, out_b, sum = instance.skip_inout_param a, c, num1, num2
      _(result).must_equal true
      _(out_b).must_equal a + 1
      _(sum).must_equal num1 + 10 * num2
    end

    it 'has a working method #skip_out_param' do
      a = 1
      c = 2.0
      d = 3
      num1 = 4
      num2 = 5
      result, out_d, sum = instance.skip_out_param a, c, d, num1, num2
      _(result).must_equal true
      _(out_d).must_equal d + 1
      _(sum).must_equal num1 + 10 * num2
    end

    it 'has a working method #skip_param' do
      a = 1
      d = 3
      num1 = 4
      num2 = 5
      result, out_b, out_d, sum = instance.skip_param a, d, num1, num2
      _(result).must_equal true
      _(out_b).must_equal a + 1
      _(out_d).must_equal d + 1
      _(sum).must_equal num1 + 10 * num2
    end

    it 'has a working method #skip_return_val' do
      a = 1
      c = 2.0
      d = 3
      num1 = 4
      num2 = 5
      out_b, out_d, out_sum = instance.skip_return_val a, c, d, num1, num2
      _(out_b).must_equal a + 1
      _(out_d).must_equal d + 1
      _(out_sum).must_equal num1 + 10 * num2
    end

    it 'has a working method #skip_return_val_no_out' do
      result = instance.skip_return_val_no_out 1
      _(result).must_be_nil

      _(proc { instance.skip_return_val_no_out 0 }).must_raise GirFFI::GLibError
    end

    it 'has a working method #torture_signature_0' do
      y, z, q = instance.torture_signature_0(-21, 'hello', 13)
      assert_equal [-21, 2 * -21, 'hello'.length + 13],
                   [y, z, q]
    end

    it 'has a working method #torture_signature_1' do
      ret, y, z, q = instance.torture_signature_1(-21, 'hello', 12)
      _([ret, y, z, q]).must_equal [true, -21, 2 * -21, 'hello'.length + 12]

      _(proc { instance.torture_signature_1(-21, 'hello', 11) }).
        must_raise GirFFI::GLibError
    end

    describe "its 'bare' property" do
      it 'can be retrieved with #get_property' do
        _(instance.get_property('bare')).must_be_nil
      end

      it 'can be retrieved with #bare' do
        _(instance.bare).must_be_nil
      end

      it 'can be set with #set_property' do
        obj = Regress::TestObj.new_from_file('bar')
        instance.set_property 'bare', obj
        _(instance.get_property('bare')).must_equal obj
      end

      it 'can be set with #bare=' do
        obj = Regress::TestObj.new_from_file('bar')
        instance.bare = obj

        _(instance.bare).must_equal obj
        _(instance.get_property('bare')).must_equal obj
      end
    end

    describe "its 'boxed' property" do
      it 'can be retrieved with #get_property' do
        _(instance.get_property('boxed')).must_be_nil
      end

      it 'can be retrieved with #boxed' do
        _(instance.boxed).must_be_nil
      end

      it 'can be set with #set_property' do
        tb = Regress::TestBoxed.new_alternative_constructor1 75
        instance.set_property 'boxed', tb
        _(instance.get_property('boxed').some_int8).must_equal 75
      end

      it 'can be set with #boxed=' do
        tb = Regress::TestBoxed.new_alternative_constructor1 75
        instance.boxed = tb
        _(instance.boxed.some_int8).must_equal tb.some_int8
        _(instance.get_property('boxed').some_int8).must_equal tb.some_int8
      end
    end

    describe "its 'byte-array' property" do
      before { skip_below('1.57.2') }

      it 'can be retrieved with #get_property' do
        _(instance.get_property('byte-array')).must_be_nil
      end

      it 'can be retrieved with #byte_array' do
        _(instance.byte_array).must_be_nil
      end

      it 'can be set with #set_property' do
        instance.set_property 'byte-array', 'hello'
        _(instance.get_property('byte-array').to_string).must_equal 'hello'
      end

      it 'can be set with #byte_array=' do
        instance.byte_array = 'bye'
        _(instance.byte_array.to_string).must_equal 'bye'
        instance.byte_array = GLib::ByteArray.from('byebye')
        _(instance.get_property('byte-array').to_string).must_equal 'byebye'
      end
    end

    describe "its 'double' property" do
      it 'can be retrieved with #get_property' do
        _(instance.get_property('double')).must_equal 0.0
      end

      it 'can be retrieved with #double' do
        _(instance.double).must_equal 0.0
      end

      it 'can be set with #set_property' do
        instance.set_property 'double', 3.14
        _(instance.get_property('double')).must_equal 3.14
      end

      it 'can be set with #double=' do
        instance.double = 3.14
        _(instance.double).must_equal 3.14
        _(instance.get_property('double')).must_equal 3.14
      end
    end

    describe "its 'float' property" do
      it 'can be retrieved with #get_property' do
        _(instance.get_property('float')).must_equal 0.0
      end

      it 'can be retrieved with #float' do
        _(instance.float).must_equal 0.0
      end

      it 'can be set with #set_property' do
        instance.set_property 'float', 3.14
        _(instance.get_property('float')).must_be_close_to 3.14
      end

      it 'can be set with #float=' do
        instance.float = 3.14
        _(instance.float).must_be_close_to 3.14
        _(instance.get_property('float')).must_be_close_to 3.14
      end
    end

    describe "its 'gtype' property" do
      it 'can be retrieved with #get_property' do
        _(instance.get_property('gtype')).must_equal 0
      end

      it 'can be retrieved with #gtype' do
        _(instance.gtype).must_equal 0
      end

      it 'can be set with #set_property' do
        instance.set_property 'gtype', GObject::TYPE_INT64
        _(instance.get_property('gtype')).must_equal GObject::TYPE_INT64
      end

      it 'can be set with #gtype=' do
        instance.gtype = GObject::TYPE_STRING
        _(instance.gtype).must_equal GObject::TYPE_STRING
        _(instance.get_property('gtype')).must_equal GObject::TYPE_STRING
      end
    end

    describe "its 'hash-table' property" do
      it 'can be retrieved with #get_property' do
        _(instance.get_property('hash-table')).must_be_nil
      end

      it 'can be retrieved with #hash_table' do
        _(instance.hash_table).must_be_nil
      end

      it 'can be set with #set_property' do
        instance.set_property 'hash-table', 'foo' => -4, 'bar' => 83
        _(instance.hash_table.to_hash).must_equal('foo' => -4, 'bar' => 83)
      end

      it 'can be set with #hash_table=' do
        instance.hash_table = { 'foo' => -4, 'bar' => 83 }
        _(instance.hash_table.to_hash).must_equal('foo' => -4, 'bar' => 83)
        _(instance.get_property('hash-table').to_hash).must_equal('foo' => -4,
                                                                        'bar' => 83)
      end
    end

    describe "its 'hash-table-old' property" do
      it 'can be retrieved with #get_property' do
        _(instance.get_property('hash-table-old')).must_be_nil
      end

      it 'can be retrieved with #hash_table_old' do
        _(instance.hash_table_old).must_be_nil
      end

      it 'can be set with #set_property' do
        instance.set_property 'hash-table-old', 'foo' => 34, 'bar' => -3
        _(instance.hash_table_old.to_hash).must_equal('foo' => 34, 'bar' => -3)
      end

      it 'can be set with #hash_table_old=' do
        instance.hash_table_old = { 'foo' => 34, 'bar' => -3 }
        _(instance.hash_table_old.to_hash).must_equal('foo' => 34, 'bar' => -3)
        _(instance.get_property('hash-table-old').to_hash).must_equal('foo' => 34,
                                                                            'bar' => -3)
      end
    end

    describe "its 'int' property" do
      it 'can be retrieved with #get_property' do
        assert_equal 0, instance.get_property('int')
      end

      it 'can be retrieved with #int' do
        assert_equal 0, instance.int
      end

      it 'can be set with #set_property' do
        instance.set_property 'int', 42
        assert_equal 42, instance.get_property('int')
      end

      it 'can be set with #int=' do
        instance.int = 41
        assert_equal 41, instance.get_property('int')
        assert_equal 41, instance.int
      end
    end

    describe "its 'list' property" do
      it 'can be retrieved with #get_property' do
        _(instance.get_property('list')).must_be_nil
      end

      it 'can be retrieved with #list' do
        _(instance.list).must_be_nil
      end

      it 'can be set with #set_property' do
        instance.set_property 'list', %w(foo bar)
        _(instance.list.to_a).must_equal %w(foo bar)
      end

      it 'can be set with #list=' do
        instance.list = %w(foo bar)
        _(instance.list.to_a).must_equal %w(foo bar)
        _(instance.get_property('list')).must_be :==, %w(foo bar)
      end
    end

    describe "its 'list-old' property" do
      it 'can be retrieved with #get_property' do
        _(instance.get_property('list-old')).must_be_nil
      end

      it 'can be retrieved with #list_old' do
        _(instance.list_old).must_be_nil
      end

      it 'can be set with #set_property' do
        instance.set_property 'list-old', %w(foo bar)
        _(instance.list_old).must_be :==, %w(foo bar)
      end

      it 'can be set with #list_old=' do
        instance.list_old = %w(foo bar)
        _(instance.list_old).must_be :==, %w(foo bar)
        _(instance.get_property('list-old')).must_be :==, %w(foo bar)
      end
    end

    describe "its 'name-conflict' property" do
      before { skip_below '1.53.4' }

      it 'can be retrieved with #get_property' do
        _(instance.get_property('name-conflict')).must_equal 42
      end

      it 'cannot be retrieved with #name_conflict' do
        # Method names are prioritized over property names, so we call the
        # method here instead of fetching the property
        _(instance.name_conflict).must_be_nil
      end

      it 'can be set with #set_property' do
        instance.set_property('name-conflict', 23)
        _(instance.get_property('name-conflict')).must_equal 23
      end

      it 'can be set with #name_conflict=' do
        instance.name_conflict = 23
        _(instance.get_property('name-conflict')).must_equal 23
      end
    end
    describe "its 'pptrarray' property" do
      before do
        skip 'The pptrarray property is not implemented properly'
      end

      it 'can be retrieved with #get_property' do
        _(instance.get_property('pptrarray')).must_be_nil
      end

      it 'can be retrieved with #pptrarray' do
        _(instance.pptrarray).must_be_nil
      end

      it 'can be set with #set_property' do
        arr = Regress.test_garray_container_return
        instance.set_property 'pptrarray', arr
        _(instance.pptrarray).must_be :==, arr
      end

      it 'can be set with #pptrarray=' do
        arr = Regress.test_garray_container_return
        instance.pptrarray = arr
        _(instance.pptrarray).must_be :==, arr
        _(instance.get_property('pptrarray')).must_be :==, arr
      end
    end

    describe "its 'string' property" do
      it 'can be retrieved with #get_property' do
        assert_nil instance.get_property('string')
      end

      it 'can be retrieved with #string' do
        assert_nil instance.string
      end

      it 'can be set with #set_property' do
        instance.set_property 'string', 'foobar'
        assert_equal 'foobar', instance.get_property('string')
      end

      it 'can be set with #string=' do
        instance.string = 'foobar'
        assert_equal 'foobar', instance.string
        assert_equal 'foobar', instance.get_property('string')
      end
    end

    describe "its 'write-only' property" do
      before { skip_below '1.59.1' }

      it 'cannot be retrieved with #get_property' do
        skip 'Not implemented yet'
        _(proc { instance.get_property('write-only') }).must_raise GirFFI::GLibError
      end

      it 'cannot be retrieved with #write_only' do
        skip 'Not implemented yet'
        _(proc { instance.write_only }).must_raise NoMethodError
      end

      it 'can be set with #set_property' do
        instance.int = 42
        instance.set_property('write-only', false)
        _(instance.int).must_equal 42
        instance.set_property('write-only', true)
        _(instance.int).must_equal 0
      end

      it 'can be set with #write_only=' do
        instance.int = 42
        instance.write_only = false
        _(instance.int).must_equal 42
        instance.write_only = true
        _(instance.int).must_equal 0
      end
    end
    it "handles the 'all' signal" do
      a = nil
      GObject.signal_connect(instance, 'all') { a = 4 }
      GObject.signal_emit instance, 'all'
      _(a).must_equal 4
    end

    it "handles the 'cleanup' signal" do
      a = nil
      GObject.signal_connect(instance, 'cleanup') { a = 4 }
      GObject.signal_emit instance, 'cleanup'
      _(a).must_equal 4
    end

    it "handles the 'first' signal" do
      a = nil
      GObject.signal_connect(instance, 'first') { a = 4 }
      GObject.signal_emit instance, 'first'
      _(a).must_equal 4
    end

    it "handles the 'sig-with-array-len-prop' signal" do
      a = nil

      GObject.signal_connect(instance, 'sig-with-array-len-prop') do |_obj, arr, _user_data|
        a = arr
      end

      arr = GirFFI::InPointer.from_array(:uint, [1, 2, 3])
      GObject.signal_emit instance, 'sig-with-array-len-prop', arr, 3

      _(a.to_a).must_equal [1, 2, 3]
    end

    it "handles the 'sig-with-array-prop' signal" do
      a = nil
      GObject.signal_connect(instance, 'sig-with-array-prop') { |_, arr, _| a = arr }
      GObject.signal_emit instance, 'sig-with-array-prop',
                          GLib::Array.from(:uint, [1, 2, 3])
      _(a.to_a).must_equal [1, 2, 3]
    end

    it "handles the 'sig-with-foreign-struct' signal" do
      a = nil
      instance.signal_connect 'sig-with-foreign-struct' do |_obj, ct|
        a = ct
      end

      cairo_context = Regress.test_cairo_context_full_return

      GObject.signal_emit instance, 'sig-with-foreign-struct', cairo_context

      _(a).must_be_instance_of Cairo::Context
      _(a).must_equal cairo_context
    end

    it "handles the 'sig-with-gerror' signal" do
      skip_below '1.61.1'
      skip 'Not implemented yet'
      a = nil
      GObject.signal_connect(instance, 'sig-with-gerror') { a = 4 }
      GObject.signal_emit instance, 'sig-with-gerror'
      _(a).must_equal 4
    end

    it "handles the 'sig-with-hash-prop' signal" do
      a = nil

      GObject.signal_connect(instance, 'sig-with-hash-prop') do |_, ghash, _|
        a = ghash.to_hash
      end

      g_hash_table = GLib::HashTable.from([:utf8, GObject::Value],
                                          'foo' => GObject::Value.from('bar'))

      GObject.signal_emit instance, 'sig-with-hash-prop', g_hash_table

      _(a['foo']).must_be_instance_of GObject::Value
      _(a['foo'].get_value).must_equal 'bar'
    end

    it "handles the 'sig-with-inout-int' signal" do
      skip_below '1.53.4'
      skip 'Not implemented yet'
      GObject.signal_connect instance, 'sig-with-inout-int' do |_obj, i, _ud|
        i + 2
      end
      result = GObject.signal_emit instance, 'sig-with-inout-int', 65
      _(result).must_equal 67
    end

    it "handles the 'sig-with-int64-prop' signal" do
      a = nil

      GObject.signal_connect(instance, 'sig-with-int64-prop') do |_obj, int64, _user_data|
        a = int64
      end

      result = GObject.signal_emit instance, 'sig-with-int64-prop', 0x7fff_ffff_ffff_ffff

      _(a).must_equal 0x7fff_ffff_ffff_ffff
      _(result).must_equal 0x7fff_ffff_ffff_ffff
    end

    it "handles the 'sig-with-intarray-ret' signal" do
      a = nil

      GObject.signal_connect(instance, 'sig-with-intarray-ret') do |_, i, _|
        a = i
        [3, 2, 1]
      end

      result = GObject.signal_emit instance, 'sig-with-intarray-ret', 3

      _(a).must_equal 3

      _(result.to_a).must_equal [3, 2, 1]
    end

    it "handles the 'sig-with-obj' signal" do
      a = nil

      GObject.signal_connect(instance, 'sig-with-obj') do |_, obj, _|
        a = obj
      end

      object = Regress::TestObj.constructor
      GObject.signal_emit instance, 'sig-with-obj', object

      _(a).must_equal object
    end

    it "handles the 'sig-with-strv' signal" do
      a = nil

      GObject.signal_connect(instance, 'sig-with-strv') do |_, strs, _|
        a = strs
      end

      GObject.signal_emit instance, 'sig-with-strv', GLib::Strv.from(%w(foo bar))

      _(a.to_a).must_equal %w(foo bar)
    end

    it "handles the 'sig-with-uint64-prop' signal" do
      a = nil

      GObject.signal_connect(instance, 'sig-with-uint64-prop') do |_, uint64, _|
        a = uint64
      end

      result = GObject.signal_emit instance, 'sig-with-uint64-prop', 0xffff_ffff_ffff_ffff

      _(a).must_equal 0xffff_ffff_ffff_ffff
      _(result).must_equal 0xffff_ffff_ffff_ffff
    end

    it "handles the 'test' signal" do
      a = b = nil
      o = Regress::TestSubObj.new
      GObject.signal_connect(o, 'test', 2) { |i, d| a = d; b = i }
      GObject.signal_emit o, 'test'
      assert_equal [2, o], [a, b]
    end

    it "handles the 'test-with-static-scope-arg' signal" do
      a = nil

      GObject.signal_connect(instance, 'test-with-static-scope-arg') do |_, obj, _|
        a = obj
      end

      arg = Regress::TestSimpleBoxedA.new
      arg.some_int = 12_345
      GObject.signal_emit instance, 'test-with-static-scope-arg', arg

      _(a.some_int).must_equal 12_345
    end
  end

  describe 'Regress::TestOtherError' do
    it 'has the member :code1' do
      _(Regress::TestOtherError[:code1]).must_equal 1
    end

    it 'has the member :code2' do
      _(Regress::TestOtherError[:code2]).must_equal 2
    end

    it 'has the member :code3' do
      _(Regress::TestOtherError[:code3]).must_equal 3
    end

    it 'has a working function #quark' do
      quark = Regress::TestOtherError.quark
      _(GLib.quark_to_string(quark)).must_equal 'regress-test-other-error'
    end
  end

  describe 'Regress::TestPrivateEnum' do
    it 'has the member :public_enum_before' do
      _(Regress::TestPrivateEnum[:public_enum_before]).must_equal 1
    end
    it 'does not have the member :private' do
      _(Regress::TestPrivateEnum[:private]).must_be_nil
    end
    it 'has the member :public_enum_after' do
      _(Regress::TestPrivateEnum[:public_enum_after]).must_equal 4
    end
  end

  describe 'Regress::TestPrivateStruct' do
    let(:instance) { Regress::TestPrivateStruct.new }

    it 'has a writable field this_is_public_before' do
      _(instance.this_is_public_before).must_equal 0
      instance.this_is_public_before = 42
      _(instance.this_is_public_before).must_equal 42
    end

    it 'has a private field this_is_private' do
      skip 'This field is identified as readable in the typelib'
      _(instance).wont_respond_to :this_is_private
      _(instance).wont_respond_to :this_is_private=
    end

    it 'has a writable field this_is_public_after' do
      _(instance.this_is_public_after).must_equal 0
      instance.this_is_public_after = 42
      _(instance.this_is_public_after).must_equal 42
    end
  end

  describe 'Regress::TestReferenceCounters' do
    it 'has a writable field refcount' do
      skip 'Needs testing'
    end
    it 'has a writable field atomicrefcount' do
      skip 'Needs testing'
    end
  end

  describe 'Regress::TestReferenceEnum' do
    it 'has the member :0' do
      _(Regress::TestReferenceEnum[:"0"]).must_equal 4
    end

    it 'has the member :1' do
      _(Regress::TestReferenceEnum[:"1"]).must_equal 2
    end

    it 'has the member :2' do
      _(Regress::TestReferenceEnum[:"2"]).must_equal 54
    end

    it 'has the member :3' do
      _(Regress::TestReferenceEnum[:"3"]).must_equal 4
    end

    it 'has the member :4' do
      _(Regress::TestReferenceEnum[:"4"]).must_equal 216
    end

    it 'has the member :5' do
      _(Regress::TestReferenceEnum[:"5"]).must_equal(-217)
    end
  end

  describe 'Regress::TestSimpleBoxedA' do
    it 'creates an instance using #new' do
      obj = Regress::TestSimpleBoxedA.new
      assert_instance_of Regress::TestSimpleBoxedA, obj
    end

    let(:instance) { Regress::TestSimpleBoxedA.new }

    it 'has a writable field some_int' do
      _(instance.some_int).must_equal 0
      instance.some_int = 42
      _(instance.some_int).must_equal 42
    end

    it 'has a writable field some_int8' do
      _(instance.some_int8).must_equal 0
      instance.some_int8 = 42
      _(instance.some_int8).must_equal 42
    end

    it 'has a writable field some_double' do
      _(instance.some_double).must_equal 0.0
      instance.some_double = 42.0
      _(instance.some_double).must_equal 42.0
    end

    it 'has a writable field some_enum' do
      _(instance.some_enum).must_equal :value1
      instance.some_enum = :value4
      _(instance.some_enum).must_equal :value4
    end

    it 'has a working method #copy' do
      instance.some_int = 4236

      obj2 = instance.copy
      _(obj2).must_be_instance_of Regress::TestSimpleBoxedA
      _(obj2.some_int).must_equal instance.some_int

      instance.some_int = 89
      _(obj2.some_int).wont_equal instance.some_int
    end

    it 'has a working method #equals' do
      instance.some_int = 4236

      ob2 = Regress::TestSimpleBoxedA.new
      ob2.some_int = 4236
      _(ob2.equals(instance)).must_equal true
      ob2.some_enum = :value3
      _(ob2.equals(instance)).must_equal true
      ob2.some_int = 42
      _(ob2.equals(instance)).wont_equal true
    end

    it 'has a working function #const_return' do
      result = Regress::TestSimpleBoxedA.const_return
      _([result.some_int, result.some_int8, result.some_double]).must_equal [5, 6, 7.0]
    end
  end

  describe 'Regress::TestSimpleBoxedB' do
    let(:instance) { Regress::TestSimpleBoxedB.new }
    it 'has a writable field some_int8' do
      _(instance.some_int8).must_equal 0
      instance.some_int8 = 42
      _(instance.some_int8).must_equal 42
    end

    it 'has a writable field nested_a' do
      _(instance.nested_a.some_int).must_equal 0
      instance.nested_a = Regress::TestSimpleBoxedA.const_return
      _(instance.nested_a.some_int).must_equal 5
    end

    it 'has a working method #copy' do
      instance.some_int8 = -42
      instance.nested_a.some_int = 4242

      copy = instance.copy
      _([copy.some_int8, copy.nested_a.some_int]).must_equal [-42, 4242]

      instance.some_int8 = 103
      _(copy.some_int8).must_equal(-42)
    end
  end

  describe 'Regress::TestStructA' do
    let(:instance) { Regress::TestStructA.new }
    it 'has a writable field some_int' do
      _(instance.some_int).must_equal 0
      instance.some_int = 2556
      _(instance.some_int).must_equal 2556
    end

    it 'has a writable field some_int8' do
      _(instance.some_int8).must_equal 0
      instance.some_int8 = -10
      _(instance.some_int8).must_equal(-10)
    end

    it 'has a writable field some_double' do
      _(instance.some_double).must_equal 0.0
      instance.some_double = 1.03455e20
      _(instance.some_double).must_equal 1.03455e20
    end

    it 'has a writable field some_enum' do
      _(instance.some_enum).must_equal :value1
      instance.some_enum = :value2
      _(instance.some_enum).must_equal :value2
    end

    it 'has a working method #clone' do
      a = Regress::TestStructA.new
      a.some_int = 2556
      a.some_int8 = -10
      a.some_double = 1.03455e20
      a.some_enum = :value2

      b = a.clone

      assert_equal 2556, b.some_int
      assert_equal(-10, b.some_int8)
      assert_equal 1.03455e20, b.some_double
      assert_equal :value2, b.some_enum
    end

    it 'has a working function #parse' do
      a = Regress::TestStructA.parse('this string is actually ignored')
      _(a.some_int).must_equal 23
    end
  end

  describe 'Regress::TestStructB' do
    let(:instance) { Regress::TestStructB.new }
    it 'has a writable field some_int8' do
      _(instance.some_int8).must_equal 0
      instance.some_int8 = 42
      _(instance.some_int8).must_equal 42
    end

    it 'has a writable field nested_a' do
      _(instance.nested_a.some_int).must_equal 0

      nested = Regress::TestStructA.new
      nested.some_int = -4321

      instance.nested_a = nested
      _(instance.nested_a.some_int).must_equal(-4321)
    end

    it 'has a working method #clone' do
      a = Regress::TestStructB.new
      a.some_int8 = 42
      a.nested_a.some_int = 2556
      a.nested_a.some_int8 = -10
      a.nested_a.some_double = 1.03455e20
      a.nested_a.some_enum = :value2

      b = a.clone

      assert_equal 42, b.some_int8
      assert_equal 2556, b.nested_a.some_int
      assert_equal(-10, b.nested_a.some_int8)
      assert_equal 1.03455e20, b.nested_a.some_double
      assert_equal :value2, b.nested_a.some_enum
    end
  end

  describe 'Regress::TestStructC' do
    let(:instance) { Regress::TestStructC.new }
    it 'has a writable field another_int' do
      _(instance.another_int).must_equal 0
      instance.another_int = 42
      _(instance.another_int).must_equal 42
    end

    it 'has a writable field obj' do
      o = Regress::TestSubObj.new
      _(instance.obj).must_be_nil
      instance.obj = o
      _(instance.obj).must_equal o
    end
  end

  describe 'Regress::TestStructD' do
    let(:instance) { Regress::TestStructD.new }
    it 'has a writable field array1' do
      _(instance.array1).must_be :==, []
      struct = Regress::TestStructA.new
      instance.array1 = [struct]
      _(instance.array1).must_be :==, [struct]
    end

    it 'has a writable field array2' do
      _(instance.array2).must_be :==, []
      o = Regress::TestSubObj.new
      instance.array2 = [o]
      _(instance.array2).must_be :==, [o]
    end

    it 'has a writable field field' do
      _(instance.field).must_be_nil
      o = Regress::TestSubObj.new
      instance.field = o
      _(instance.field).must_equal o
    end

    it 'has a writable field list' do
      _(instance.list).must_be_nil
      o = Regress::TestSubObj.new
      instance.list = [o]
      _(instance.list).must_be :==, [o]
    end

    it 'has a writable field garray' do
      _(instance.garray).must_be_nil
      o = Regress::TestSubObj.new
      instance.garray = [o]
      _(instance.garray).must_be :==, [o]
    end
  end

  describe 'Regress::TestStructE' do
    let(:instance) { Regress::TestStructE.new }
    it 'has a writable field some_type' do
      _(instance.some_type).must_equal 0
      instance.some_type = GObject::TYPE_STRING
      _(instance.some_type).must_equal GObject::TYPE_STRING
    end

    it 'has a writable field some_union' do
      _(instance.some_union.map(&:v_int)).must_equal [0, 0]

      union1 = Regress::TestStructE__some_union__union.new
      union1.v_int = 42
      union2 = Regress::TestStructE__some_union__union.new
      union2.v_int = 84

      instance.some_union = [union1, union2]

      _(instance.some_union.map(&:v_int)).must_equal [42, 84]
    end
  end
  describe 'Regress::TestStructE__some_union__union' do
    let(:instance) { Regress::TestStructE__some_union__union.new }
    it 'has a writable field v_int' do
      _(instance.v_int).must_equal 0
      instance.v_int = -54_321
      _(instance.v_int).must_equal(-54_321)
    end

    it 'has a writable field v_uint' do
      _(instance.v_uint).must_equal 0
      instance.v_uint = 54_321
      _(instance.v_uint).must_equal 54_321
    end

    it 'has a writable field v_long' do
      _(instance.v_long).must_equal 0
      instance.v_long = -54_321
      _(instance.v_long).must_equal(-54_321)
    end

    it 'has a writable field v_ulong' do
      _(instance.v_long).must_equal 0
      instance.v_long = 54_321
      _(instance.v_long).must_equal 54_321
    end

    it 'has a writable field v_int64' do
      _(instance.v_int64).must_equal 0
      instance.v_int64 = -54_321_000_000_000
      _(instance.v_int64).must_equal(-54_321_000_000_000)
    end
    it 'has a writable field v_uint64' do
      _(instance.v_uint64).must_equal 0
      instance.v_uint64 = 54_321_000_000_000
      _(instance.v_uint64).must_equal 54_321_000_000_000
    end
    it 'has a writable field v_float' do
      _(instance.v_float).must_equal 0
      instance.v_float = 3.1415
      _(instance.v_float).must_be_close_to 3.1415
    end
    it 'has a writable field v_double' do
      _(instance.v_double).must_equal 0
      instance.v_double = 3.1415
      _(instance.v_double).must_equal 3.1415
    end
    it 'has a writable field v_pointer' do
      _(instance.v_pointer).must_be :null?
      instance.v_pointer = FFI::Pointer.new 54_321
      _(instance.v_pointer.address).must_equal 54_321
    end
  end
  describe 'Regress::TestStructF' do
    let(:instance) { Regress::TestStructF.new }

    it 'has a writable field ref_count' do
      _(instance.ref_count).must_equal 0
      instance.ref_count = 1
      _(instance.ref_count).must_equal 1
    end

    it 'has a writable field data1' do
      _(instance.data1).must_be :null?
      instance.data1 = FFI::MemoryPointer.new(:int32).tap { |it| it.put_int(0, 42) }
      _(instance.data1.read_int).must_equal 42
    end

    # TODO: Check what gobject-introspection should/will do with these fields.
    it 'has a writable field data2' do
      skip 'Introspection data cannot deal with type of this field yet'
    end

    it 'has a writable field data3' do
      skip 'Introspection data cannot deal with type of this field yet'
    end

    it 'has a writable field data4' do
      skip 'Introspection data cannot deal with type of this field yet'
    end

    it 'has a writable field data5' do
      skip 'Introspection data cannot deal with type of this field yet'
    end

    it 'has a writable field data6' do
      skip 'Introspection data cannot deal with type of this field yet'
    end

    it 'has a writable field data7' do
      skip_below '1.59.3'
      instance.data7 = 42
      _(instance.data7).must_equal 42
    end
  end

  describe 'Regress::TestStructFixedArray' do
    let(:instance) { Regress::TestStructFixedArray.new }
    it 'has a writable field just_int' do
      _(instance.just_int).must_equal 0
      instance.just_int = 42
      _(instance.just_int).must_equal 42
    end

    it 'has a writable field array' do
      _(instance.array).must_be :==, [0] * 10
      instance.array = (1..10).to_a
      _(instance.array).must_be :==, (1..10).to_a
    end

    it 'has a working method #frob' do
      instance.array = (0..9).to_a
      instance.frob
      _(instance.array).must_be :==, (42..42 + 9).to_a
      _(instance.just_int).must_equal 7
    end
  end

  describe 'Regress::TestSubObj' do
    it 'creates an instance using #new' do
      tso = Regress::TestSubObj.new
      assert_instance_of Regress::TestSubObj, tso
    end

    it "does not create an instance using its parent object's custom constructors" do
      _(proc { Regress::TestSubObj.constructor }).must_raise NoMethodError
    end

    let(:instance) { Regress::TestSubObj.new }

    it 'has a working method #instance_method' do
      res = instance.instance_method
      assert_equal 0, res
    end

    it 'has a working method #unset_bare' do
      instance.unset_bare
      pass
    end

    describe "its 'boolean' property" do
      before { skip_below '1.59.1' }

      it 'can be retrieved with #get_property' do
        _(instance.get_property('boolean')).must_equal true
      end

      it 'can be retrieved with #boolean' do
        _(instance.boolean).must_equal true
      end

      it 'can be set with #set_property' do
        instance.set_property('boolean', false)
        _(instance.get_property('boolean')).must_equal false
      end

      it 'can be set with #boolean=' do
        instance.boolean = false
        _(instance.get_property('boolean')).must_equal false
      end
    end

    it 'does not have a field parent_instance' do
      _(instance).wont_respond_to :parent_instance
    end
  end

  describe 'Regress::TestWi8021x' do
    it 'creates an instance using #new' do
      o = Regress::TestWi8021x.new
      assert_instance_of Regress::TestWi8021x, o
    end

    it 'has a working function #static_method' do
      assert_equal(-84, Regress::TestWi8021x.static_method(-42))
    end

    let(:instance) { Regress::TestWi8021x.new }

    it 'has a working method #get_testbool' do
      _(instance.get_testbool).must_equal true
    end

    it 'has a working method #set_testbool' do
      instance.set_testbool true
      _(instance.get_testbool).must_equal true
      instance.set_testbool false
      _(instance.get_testbool).must_equal false
    end

    describe "its 'testbool' property" do
      it 'can be retrieved with #get_property' do
        _(instance.get_property('testbool')).must_equal true
      end

      it 'can be retrieved with #testbool' do
        _(instance.testbool).must_equal true
      end

      it 'can be set with #set_property' do
        instance.set_property 'testbool', true
        _(instance.get_testbool).must_equal true
        _(instance.get_property('testbool')).must_equal true

        instance.set_property 'testbool', false
        _(instance.get_testbool).must_equal false
        _(instance.get_property('testbool')).must_equal false
      end

      it 'can be set with #testbool=' do
        instance.testbool = true
        _(instance.testbool).must_equal true
        _(instance.get_testbool).must_equal true
        _(instance.get_property('testbool')).must_equal true

        instance.testbool = false
        _(instance.testbool).must_equal false
        _(instance.get_testbool).must_equal false
        _(instance.get_property('testbool')).must_equal false
      end
    end
  end

  it 'has the constant UTF8_CONSTANT' do
    assert_equal 'const ♥ utf8', Regress::UTF8_CONSTANT
  end

  it 'has a working function #aliased_caller_alloc' do
    result = Regress.aliased_caller_alloc
    _(result).must_be_instance_of Regress::TestBoxed
  end

  it 'has a working function #annotation_attribute_func' do
    info = get_introspection_data('Regress', 'annotation_attribute_func')
    param = info.args.last
    _(param.attribute('some.annotation')).must_equal 'value'
    _(param.attribute('another.annotation')).must_equal 'blahvalue'

    obj = Regress::AnnotationObject.new
    _(Regress.annotation_attribute_func(obj, 'hello')).must_equal 42
  end

  it 'has a working function #annotation_custom_destroy' do
    result = Regress.annotation_custom_destroy {}
    _(result).must_be_nil
  end

  it 'has a working function #annotation_get_source_file' do
    _(Regress.annotation_get_source_file).must_be_nil
  end

  it 'has a working function #annotation_init' do
    result = Regress.annotation_init %w(foo bar)
    _(result.to_a).must_equal %w(foo bar)
  end

  it 'has a working function #annotation_invalid_regress_annotation' do
    _(Regress.annotation_invalid_regress_annotation(42)).must_be_nil
  end

  it 'has a working function #annotation_ptr_array' do
    # TODO: Automatically convert array elements to correct type
    val1 = GObject::Value.from 1
    val2 = GObject::Value.from 'a'
    _(Regress.annotation_ptr_array([val1, val2])).must_be_nil
  end

  it 'has a working function #annotation_return_array' do
    _(Regress.annotation_return_array).must_be_nil
  end

  it 'has a working function #annotation_return_filename' do
    skip 'This function is wrongly annotated as transfer-ownership: full'
    _(Regress.annotation_return_filename).must_equal 'a utf-8 filename'
  end

  it 'has a working function #annotation_set_source_file' do
    _(Regress.annotation_set_source_file('a filename')).must_be_nil
  end

  it 'has a working function #annotation_space_after_comment_bug631690' do
    _(Regress.annotation_space_after_comment_bug631690).must_be_nil
  end

  it 'has a working function #annotation_string_array_length' do
    _(Regress.annotation_string_array_length(%w(foo bar))).must_be_nil
  end

  it 'has a working function #annotation_string_zero_terminated' do
    _(Regress.annotation_string_zero_terminated.to_a).must_equal []
  end

  it 'has a working function #annotation_string_zero_terminated_out' do
    _(Regress.annotation_string_zero_terminated_out(%w(foo bar)).to_a).
      must_equal %w(foo bar)
  end

  it 'has a working function #annotation_test_parsing_bug630862' do
    _(Regress.annotation_test_parsing_bug630862).must_be_nil
  end

  it 'has a working function #annotation_transfer_floating' do
    Regress.setup_method! :annotation_transfer_floating
    method = Regress.method :annotation_transfer_floating
    # NOTE: The arity of this method was changed in GObjectIntrospection 1.53.2
    if method.arity == 1
      object = GObject::Object.new
      _(Regress.annotation_transfer_floating(object)).must_be_nil
    else
      _(Regress.annotation_transfer_floating).must_be_nil
    end
  end

  it 'has a working function #annotation_versioned' do
    _(Regress.annotation_versioned).must_be_nil
  end

  it 'has a working function #atest_error_quark' do
    result = Regress.atest_error_quark
    _(GLib.quark_to_string(result)).must_equal 'regress-atest-error'
  end

  it 'has a working function #foo_async_ready_callback' do
    skip 'This function is defined in the header but not implemented'
  end

  it 'has a working function #foo_destroy_notify_callback' do
    skip 'This function is defined in the header but not implemented'
  end

  it 'has a working function #foo_enum_type_method' do
    skip 'This function is defined in the header but not implemented'
  end

  it 'has a working function #foo_enum_type_returnv' do
    skip 'This function is defined in the header but not implemented'
  end

  it 'has a working function #foo_error_quark' do
    result = Regress.foo_error_quark
    _(GLib.quark_to_string(result)).must_equal('regress_foo-error-quark')
  end

  it 'has a working function #foo_init' do
    _(Regress.foo_init).must_equal 0x1138
  end

  it 'has a working function #foo_interface_static_method' do
    _(Regress.foo_interface_static_method(42)).must_be_nil
  end

  it 'has a working function #foo_method_external_references' do
    skip 'This function is defined in the header but not implemented'
  end

  it 'has a working function #foo_not_a_constructor_new' do
    _(Regress.foo_not_a_constructor_new).must_be_nil
  end

  it 'has a working function #foo_test_array' do
    _(Regress.foo_test_array).must_be_nil
  end

  it 'has a working function #foo_test_const_char_param' do
    skip 'This function is defined in the header but not implemented'
  end

  it 'has a working function #foo_test_const_char_retval' do
    skip 'This function is defined in the header but not implemented'
  end

  it 'has a working function #foo_test_const_struct_param' do
    skip 'This function is defined in the header but not implemented'
  end

  it 'has a working function #foo_test_const_struct_retval' do
    skip 'This function is defined in the header but not implemented'
  end

  it 'has a working function #foo_test_string_array' do
    _(Regress.foo_test_string_array(%w(foo bar))).must_be_nil
  end

  it 'has a working function #foo_test_string_array_with_g' do
    _(Regress.foo_test_string_array_with_g(%w(foo bar))).must_be_nil
  end

  it 'has a working function #foo_test_unsigned_qualifier' do
    skip 'This function is defined in the header but not implemented'
  end

  it 'has a working function #foo_test_unsigned_type' do
    skip 'This function is defined in the header but not implemented'
  end

  it 'has a working function #func_obj_null_in' do
    Regress.func_obj_null_in nil
    Regress.func_obj_null_in Regress::TestObj.constructor
    pass
  end

  it 'has a working function #func_obj_nullable_in' do
    Regress.func_obj_null_in nil
    Regress.func_obj_null_in Regress::TestObj.constructor
    pass
  end

  it 'has a working function #get_variant' do
    skip_below '1.47.92'
    var = Regress.get_variant
    _(var.get_int32).must_equal 42
    # TODO: Make var not floating
  end

  it 'has a working function #global_get_flags_out' do
    result = Regress.global_get_flags_out
    _(result).must_equal(flag1: true, flag3: true)
  end

  it 'has a working function #has_parameter_named_attrs' do
    Regress.has_parameter_named_attrs 42, [23] * 32
    pass
  end

  it 'has a working function #introspectable_via_alias' do
    Regress.introspectable_via_alias []
    pass
  end

  it 'has a working function #set_abort_on_error' do
    Regress.set_abort_on_error false
    Regress.set_abort_on_error true
    pass
  end

  it 'has a working function #test_abc_error_quark' do
    quark = Regress.test_abc_error_quark
    _(GLib.quark_to_string(quark)).must_equal 'regress-test-abc-error'
  end

  it 'has a working function #test_array_callback' do
    a = nil
    b = nil
    c = 95

    result = Regress.test_array_callback do |one, two|
      a = one
      b = two
      c
    end

    _(result).must_equal 2 * c
    _(a.to_a).must_equal [-1, 0, 1, 2]
    _(b.to_a).must_equal %w(one two three)
  end

  it 'has a working function #test_array_fixed_out_objects' do
    result = Regress.test_array_fixed_out_objects
    gtype = Regress::TestObj.gtype

    _(result.size).must_equal 2

    result.each do |o|
      assert_instance_of Regress::TestObj, o
      assert_equal gtype, GObject.type_from_instance(o)
    end
  end

  it 'has a working function #test_array_fixed_size_int_in' do
    assert_equal 5 + 4 + 3 + 2 + 1, Regress.test_array_fixed_size_int_in([5, 4, 3, 2, 1])
  end

  describe '#test_array_fixed_size_int_in' do
    it 'raises an error when called with the wrong number of arguments' do
      assert_raises ArgumentError do
        Regress.test_array_fixed_size_int_in [2]
      end
    end
  end

  it 'has a working function #test_array_fixed_size_int_out' do
    _(Regress.test_array_fixed_size_int_out).must_be :==, [0, 1, 2, 3, 4]
  end

  it 'has a working function #test_array_fixed_size_int_return' do
    _(Regress.test_array_fixed_size_int_return).must_be :==, [0, 1, 2, 3, 4]
  end

  it 'has a working function #test_array_gint16_in' do
    assert_equal 5 + 4 + 3, Regress.test_array_gint16_in([5, 4, 3])
  end

  it 'has a working function #test_array_gint32_in' do
    assert_equal 5 + 4 + 3, Regress.test_array_gint32_in([5, 4, 3])
  end

  it 'has a working function #test_array_gint64_in' do
    assert_equal 5 + 4 + 3, Regress.test_array_gint64_in([5, 4, 3])
  end

  it 'has a working function #test_array_gint8_in' do
    assert_equal 5 + 4 + 3, Regress.test_array_gint8_in([5, 4, 3])
  end

  it 'has a working function #test_array_gtype_in' do
    t1 = GObject.type_from_name 'gboolean'
    t2 = GObject.type_from_name 'gint64'
    assert_equal '[gboolean,gint64,]', Regress.test_array_gtype_in([t1, t2])
  end

  it 'has a working function #test_array_inout_callback' do
    Regress.test_array_inout_callback do |ints|
      arr = ints.to_a
      arr.shift
      arr
    end
    pass
  end

  it 'has a working function #test_array_int_full_out' do
    _(Regress.test_array_int_full_out).must_be :==, [0, 1, 2, 3, 4]
  end

  it 'has a working function #test_array_int_in' do
    assert_equal 5 + 4 + 3, Regress.test_array_int_in([5, 4, 3])
  end

  it 'has a working function #test_array_int_inout' do
    _(Regress.test_array_int_inout([5, 2, 3])).must_be :==, [3, 4]
  end

  it 'has a working function #test_array_int_none_out' do
    _(Regress.test_array_int_none_out).must_be :==, [1, 2, 3, 4, 5]
  end

  it 'has a working function #test_array_int_null_in' do
    Regress.test_array_int_null_in nil
    pass
  end

  it 'has a working function #test_array_int_null_out' do
    _(Regress.test_array_int_null_out).must_be_nil
  end

  it 'has a working function #test_array_int_out' do
    _(Regress.test_array_int_out).must_be :==, [0, 1, 2, 3, 4]
  end

  it 'has a working function #test_array_struct_in_full' do
    skip_below '1.59.4'
    # FIXME: Allow passing field values to .new
    arr = [Regress::TestStructA.new.tap { |it| it.some_int = 201 },
           Regress::TestStructA.new.tap { |it| it.some_int = 202 }]
    Regress.test_array_struct_in_full(arr)
  end

  it 'has a working function #test_array_struct_in_none' do
    skip_below '1.59.4'
    # FIXME: Allow passing field values to .new
    arr = [Regress::TestStructA.new.tap { |it| it.some_int = 301 },
           Regress::TestStructA.new.tap { |it| it.some_int = 302 },
           Regress::TestStructA.new.tap { |it| it.some_int = 303 }]
    Regress.test_array_struct_in_none(arr)
  end

  it 'has a working function #test_array_struct_out' do
    skip_below '1.47.92'
    result = Regress.test_array_struct_out
    _(result.map(&:some_int)).must_equal [22, 33, 44]
  end

  it 'has a working function #test_array_struct_out_caller_alloc' do
    skip_below '1.59.4'
    skip 'Not implemented yet'
    result = Regress.test_array_struct_out_caller_alloc 3
    _(result.map(&:some_int)).must_equal [22, 33, 44]
  end

  it 'has a working function #test_array_struct_out_container' do
    skip_below '1.59.4'
    result = Regress.test_array_struct_out_container
    _(result.map(&:some_int)).must_equal [11, 13, 17, 19, 23]
  end

  it 'has a working function #test_array_struct_out_full_fixed' do
    skip_below '1.59.4'
    result = Regress.test_array_struct_out_full_fixed
    _(result.map(&:some_int)).must_equal [2, 3, 5, 7]
  end

  it 'has a working function #test_array_struct_out_none' do
    skip_below '1.59.4'
    result = Regress.test_array_struct_out_none
    _(result.map(&:some_int)).must_equal [111, 222, 333]
  end

  it 'has a working function #test_async_ready_callback' do
    main_loop = GLib::MainLoop.new nil, false

    a = 1
    Regress.test_async_ready_callback do
      main_loop.quit
      a = 2
    end

    main_loop.run

    assert_equal 2, a
  end

  it 'has a working function #test_boolean' do
    assert_equal false, Regress.test_boolean(false)
    assert_equal true, Regress.test_boolean(true)
  end

  it 'has a working function #test_boolean_false' do
    assert_equal false, Regress.test_boolean_false(false)
  end

  it 'has a working function #test_boolean_true' do
    assert_equal true, Regress.test_boolean_true(true)
  end

  it 'has a working function #test_boxeds_not_a_method' do
    boxed = Regress::TestBoxed.new_alternative_constructor1 123
    Regress.test_boxeds_not_a_method boxed
    pass
  end

  it 'has a working function #test_boxeds_not_a_static' do
    Regress.test_boxeds_not_a_static
    pass
  end

  it 'has a working function #test_cairo_context_full_return' do
    ct = Regress.test_cairo_context_full_return
    assert_instance_of Cairo::Context, ct
  end

  it 'has a working function #test_cairo_context_none_in' do
    ct = Regress.test_cairo_context_full_return
    Regress.test_cairo_context_none_in ct
  end

  it 'has a working function #test_cairo_surface_full_out' do
    cs = Regress.test_cairo_surface_full_out
    assert_instance_of Cairo::Surface, cs
  end

  it 'has a working function #test_cairo_surface_full_return' do
    cs = Regress.test_cairo_surface_full_return
    assert_instance_of Cairo::Surface, cs
  end

  it 'has a working function #test_cairo_surface_none_in' do
    cs = Regress.test_cairo_surface_full_return
    Regress.test_cairo_surface_none_in cs
  end

  it 'has a working function #test_cairo_surface_none_return' do
    cs = Regress.test_cairo_surface_none_return
    assert_instance_of Cairo::Surface, cs
  end

  it 'has a working function #test_callback' do
    result = Regress.test_callback { 5 }
    assert_equal 5, result
  end

  it 'has a working function #test_callback_async' do
    a = 1
    stored_proc = nil
    Regress.test_callback_async { |user_data| stored_proc = user_data; a = 2 }
    result = Regress.test_callback_thaw_async
    _(a).must_equal 2
    _(stored_proc).wont_be_nil
    _(result).must_equal 2
    # TODO: See when we can clean up the stored callback for async callbacks.
    stored_id = stored_proc.object_id
    _(GirFFI::CallbackBase::CALLBACKS[stored_id].object_id).must_equal stored_id
  end

  it 'has a working function #test_callback_destroy_notify' do
    a = 1
    stored_proc = nil
    r1 = Regress.test_callback_destroy_notify { |user_data| stored_proc = user_data; a = 2 }
    _(a).must_equal 2
    stored_id = stored_proc.object_id
    _(GirFFI::CallbackBase::CALLBACKS[stored_id].object_id).must_equal stored_id

    a = 3
    r2 = Regress.test_callback_thaw_notifications
    _(a).must_equal 2
    _(r1).must_equal r2
    _(GirFFI::CallbackBase::CALLBACKS[stored_id]).must_be_nil
  end

  it 'has a working function #test_callback_destroy_notify_no_user_data' do
    callback_times_called = 0
    b = :not_nil

    result = Regress.test_callback_destroy_notify_no_user_data do |user_data|
      callback_times_called += 1
      b = user_data
      callback_times_called * 5
    end

    _(callback_times_called).must_equal 1
    _(result).must_equal 5
    _(b).must_be_nil

    result = Regress.test_callback_thaw_notifications

    _(callback_times_called).must_equal 2
    _(result).must_equal 10
    _(b).must_be_nil
  end

  it 'has a working function #test_callback_return_full' do
    obj = Regress::TestObj.constructor
    Regress.test_callback_return_full { obj }
    _(object_ref_count(obj)).must_equal 1
  end

  it 'has a working function #test_callback_thaw_async' do
    invoked = []
    Regress.test_callback_async { invoked << 1; 1 }
    Regress.test_callback_async { invoked << 2; 2 }
    Regress.test_callback_async { invoked << 3; 3 }
    result = Regress.test_callback_thaw_async
    _(invoked).must_equal [3, 2, 1]
    _(result).must_equal 1
  end

  it 'has a working function #test_callback_thaw_notifications' do
    Regress.test_callback_destroy_notify { 42 }
    Regress.test_callback_destroy_notify { 24 }
    result = Regress.test_callback_thaw_notifications
    _(result).must_equal 66
  end

  it 'has a working function #test_callback_user_data' do
    stored_id = nil
    result = Regress.test_callback_user_data { |u| stored_id = u; 5 }
    # TODO: Ensure that the key stored_id is no longer in the callback store
    _(stored_id).wont_be_nil
    _(result).must_equal 5
  end

  it 'has a working function #test_closure' do
    c = GObject::RubyClosure.new { 5235 }
    r = Regress.test_closure c
    assert_equal 5235, r
  end

  it 'has a working function #test_closure_one_arg' do
    c = GObject::RubyClosure.new { |a| a * 2 }
    r = Regress.test_closure_one_arg c, 2
    assert_equal 4, r
  end

  it 'has a working function #test_closure_variant' do
    arg = GLib::Variant.new_string 'foo'

    # TODO: Convert proc to RubyClosure automatically
    closure = GObject::RubyClosure.new do |variant|
      str = variant.get_string
      if str == 'foo'
        GLib::Variant.new_int32 40
      else
        GLib::Variant.new_string 'bar'
      end
    end

    result = Regress.test_closure_variant closure, arg

    _(result.get_int32).must_equal 40
  end

  it 'has a working function #test_create_fundamental_hidden_class_instance' do
    skip 'Needs testing'
  end

  it 'has a working function #test_date_in_gvalue' do
    date = Regress.test_date_in_gvalue
    assert_equal [1984, :december, 5],
                 [date.get_year, date.get_month, date.get_day]
  end

  it 'has a working function #test_def_error_quark' do
    quark = Regress.test_def_error_quark
    _(GLib.quark_to_string(quark)).must_equal 'regress-test-def-error'
  end

  it 'has a working function #test_double' do
    r = Regress.test_double 5435.32
    assert_equal 5435.32, r
  end

  it 'has a working function #test_enum_param' do
    r = Regress.test_enum_param :value3
    assert_equal 'value3', r
  end

  it 'has a working function #test_error_quark' do
    quark = Regress.test_error_quark
    _(GLib.quark_to_string(quark)).must_equal 'regress-test-error'
  end

  it 'has a working function #test_filename_return' do
    arr = Regress.test_filename_return
    _(arr).must_be :==, ['åäö', '/etc/fstab']
  end

  it 'has a working function #test_float' do
    r = Regress.test_float 5435.32
    assert_in_delta 5435.32, r, 0.001
  end

  it 'has a working function #test_garray_container_return' do
    arr = Regress.test_garray_container_return
    _(arr).must_be_instance_of GLib::PtrArray
    _(arr.len).must_equal 1

    ptr = arr.pdata
    ptr2 = ptr.read_pointer
    _(ptr2.read_string).must_be :==, 'regress'
  end

  it 'has a working function #test_garray_full_return' do
    result = Regress.test_garray_full_return
    _(result.to_a).must_equal ['regress']
  end

  it 'has a working function #test_gerror_callback' do
    result = nil
    Regress.test_gerror_callback { |err| result = err.message }
    _(result).must_equal 'regression test error'
  end

  it 'has a working function #test_ghash_container_return' do
    hash = Regress.test_ghash_container_return
    _(hash).must_be_instance_of GLib::HashTable
    _(hash.to_hash).must_equal('foo' => 'bar',
                            'baz' => 'bat',
                            'qux' => 'quux')
  end

  it 'has a working function #test_ghash_everything_return' do
    ghash = Regress.test_ghash_everything_return
    _(ghash.to_hash).must_be :==, 'foo' => 'bar',
                               'baz' => 'bat',
                               'qux' => 'quux'
  end

  it 'has a working function #test_ghash_gvalue_in' do
    hash_table = Regress.test_ghash_gvalue_return
    Regress.test_ghash_gvalue_in hash_table
  end

  it 'has a working function #test_ghash_gvalue_return' do
    result = Regress.test_ghash_gvalue_return
    hash = result.to_hash

    has_enum_and_flag_keys = hash.key?('flags')

    _(hash['integer'].get_value).must_equal 12
    _(hash['boolean'].get_value).must_equal true
    _(hash['string'].get_value).must_equal 'some text'
    _(hash['strings'].get_value.to_a).must_equal %w(first second third)

    if has_enum_and_flag_keys
      _(hash['flags'].get_value).must_equal flag1: true, flag3: true
      _(hash['enum'].get_value).must_equal :value2
    end

    expected_keys = if has_enum_and_flag_keys
                      %w(boolean enum flags integer string strings)
                    else
                      %w(boolean integer string strings)
                    end

    _(hash.keys.sort).must_equal expected_keys
  end

  it 'has a working function #test_ghash_nested_everything_return' do
    result = Regress.test_ghash_nested_everything_return
    hash = result.to_hash
    _(hash.keys).must_equal ['wibble']
    _(hash['wibble'].to_hash).must_equal('foo' => 'bar',
                                      'baz' => 'bat',
                                      'qux' => 'quux')
  end

  it 'has a working function #test_ghash_nested_everything_return2' do
    result = Regress.test_ghash_nested_everything_return2
    hash = result.to_hash
    _(hash.keys).must_equal ['wibble']
    _(hash['wibble'].to_hash).must_equal('foo' => 'bar',
                                      'baz' => 'bat',
                                      'qux' => 'quux')
  end

  it 'has a working function #test_ghash_nothing_in' do
    Regress.test_ghash_nothing_in('foo' => 'bar',
                                  'baz' => 'bat',
                                  'qux' => 'quux')
  end

  it 'has a working function #test_ghash_nothing_in2' do
    Regress.test_ghash_nothing_in2('foo' => 'bar',
                                   'baz' => 'bat',
                                   'qux' => 'quux')
  end

  it 'has a working function #test_ghash_nothing_return' do
    ghash = Regress.test_ghash_nothing_return
    _(ghash.to_hash).must_be :==, 'foo' => 'bar',
                               'baz' => 'bat',
                               'qux' => 'quux'
  end

  it 'has a working function #test_ghash_nothing_return2' do
    ghash = Regress.test_ghash_nothing_return2
    _(ghash.to_hash).must_be :==, 'foo' => 'bar',
                               'baz' => 'bat',
                               'qux' => 'quux'
  end

  it 'has a working function #test_ghash_null_in' do
    Regress.test_ghash_null_in(nil)
  end

  it 'has a working function #test_ghash_null_out' do
    ghash = Regress.test_ghash_null_out
    _(ghash).must_be_nil
  end

  it 'has a working function #test_ghash_null_return' do
    ghash = Regress.test_ghash_null_return
    _(ghash).must_be_nil
  end

  it 'has a working function #test_glist_container_return' do
    list = Regress.test_glist_container_return
    assert_instance_of GLib::List, list
    _(list).must_be :==, %w(1 2 3)
  end

  it 'has a working function #test_glist_everything_return' do
    list = Regress.test_glist_everything_return
    _(list).must_be :==, %w(1 2 3)
  end

  it 'has a working function #test_glist_gtype_container_in' do
    Regress.test_glist_gtype_container_in [Regress::TestObj.gtype, Regress::TestSubObj.gtype]
    pass
  end

  it 'has a working function #test_glist_nothing_in' do
    Regress.test_glist_nothing_in %w(1 2 3)
    pass
  end

  it 'has a working function #test_glist_nothing_in2' do
    Regress.test_glist_nothing_in2 %w(1 2 3)
    pass
  end

  it 'has a working function #test_glist_nothing_return' do
    list = Regress.test_glist_nothing_return
    _(list).must_be :==, %w(1 2 3)
  end

  it 'has a working function #test_glist_nothing_return2' do
    list = Regress.test_glist_nothing_return2
    _(list).must_be :==, %w(1 2 3)
  end

  it 'has a working function #test_glist_null_in' do
    Regress.test_glist_null_in nil
    pass
  end

  it 'has a working function #test_glist_null_out' do
    result = Regress.test_glist_null_out
    _(result).must_be_nil
  end

  it 'has a working function #test_gslist_container_return' do
    slist = Regress.test_gslist_container_return
    assert_instance_of GLib::SList, slist
    _(slist).must_be :==, %w(1 2 3)
  end

  it 'has a working function #test_gslist_everything_return' do
    slist = Regress.test_gslist_everything_return
    _(slist).must_be :==, %w(1 2 3)
  end

  it 'has a working function #test_gslist_nothing_in' do
    Regress.test_gslist_nothing_in %w(1 2 3)
    pass
  end

  it 'has a working function #test_gslist_nothing_in2' do
    Regress.test_gslist_nothing_in2 %w(1 2 3)
    pass
  end

  it 'has a working function #test_gslist_nothing_return' do
    slist = Regress.test_gslist_nothing_return
    _(slist).must_be :==, %w(1 2 3)
  end

  it 'has a working function #test_gslist_nothing_return2' do
    slist = Regress.test_gslist_nothing_return2
    _(slist).must_be :==, %w(1 2 3)
  end

  it 'has a working function #test_gslist_null_in' do
    Regress.test_gslist_null_in nil
    pass
  end

  it 'has a working function #test_gslist_null_out' do
    result = Regress.test_gslist_null_out
    _(result).must_be_nil
  end

  it 'has a working function #test_gtype' do
    result = Regress.test_gtype 23
    assert_equal 23, result
  end

  it 'has a working function #test_gvariant_as' do
    _(Regress.test_gvariant_as.get_strv.to_a).must_equal %w(one two three)
  end

  it 'has a working function #test_gvariant_asv' do
    result = Regress.test_gvariant_asv
    _(result.n_children).must_equal 2
    _(result.lookup_value('name').get_string).must_equal 'foo'
    _(result.lookup_value('timeout').get_int32).must_equal 10
  end

  it 'has a working function #test_gvariant_i' do
    _(Regress.test_gvariant_i.get_int32).must_equal 1
  end

  it 'has a working function #test_gvariant_s' do
    _(Regress.test_gvariant_s.get_string).must_equal 'one'
  end

  it 'has a working function #test_gvariant_v' do
    _(Regress.test_gvariant_v.get_variant.get_string).must_equal 'contents'
  end

  it 'has a working function #test_hash_table_callback' do
    value = nil
    Regress.test_hash_table_callback('foo' => 42) { |hash| value = hash }
    _(value.to_hash).must_equal('foo' => 42)
  end

  it 'has a working function #test_int' do
    result = Regress.test_int 23
    assert_equal 23, result
  end

  it 'has a working function #test_int16' do
    result = Regress.test_int16 23
    assert_equal 23, result
  end

  it 'has a working function #test_int32' do
    result = Regress.test_int32 23
    assert_equal 23, result
  end

  it 'has a working function #test_int64' do
    result = Regress.test_int64 2_300_000_000_000
    assert_equal 2_300_000_000_000, result
  end

  it 'has a working function #test_int8' do
    result = Regress.test_int8 23
    assert_equal 23, result
  end

  it 'has a working function #test_int_out_utf8' do
    len = Regress.test_int_out_utf8 'How long?'
    assert_equal 9, len
  end

  it 'has a working function #test_int_value_arg' do
    gv = GObject::Value.new
    gv.init GObject.type_from_name 'gint'
    gv.set_int 343
    result = Regress.test_int_value_arg gv
    assert_equal 343, result
  end

  it 'has a working function #test_long' do
    long_val = FFI.type_size(:long) == 8 ? 2_300_000_000_000 : 2_000_000_000
    result = Regress.test_long long_val
    assert_equal long_val, result
  end

  it 'has a working function #test_multi_callback' do
    a = 1
    result = Regress.test_multi_callback do
      a += 1
      23
    end
    assert_equal 2 * 23, result
    assert_equal 3, a
  end

  it 'has a working function #test_multi_double_args' do
    one, two = Regress.test_multi_double_args 23.1
    assert_equal 2 * 23.1, one
    assert_equal 3 * 23.1, two
  end

  it 'has a working function #test_multiline_doc_comments' do
    _(Regress.test_multiline_doc_comments).must_be_nil
  end

  it 'has a working function #test_nested_parameter' do
    _(Regress.test_nested_parameter(3)).must_be_nil
  end

  it 'has a working function #test_noptr_callback' do
    skip_below '1.47.1'
    a = 0
    Regress.test_noptr_callback { a = 1 }
    _(a).must_equal 1
  end

  it 'has a working function #test_null_gerror_callback' do
    value = nil
    Regress.test_owned_gerror_callback { |err| value = err }
    _(value.message).must_equal 'regression test owned error'
  end

  it 'has a working function #test_null_strv_in_gvalue' do
    skip 'Needs testing'
  end
  it 'has a working function #test_owned_gerror_callback' do
    value = nil
    Regress.test_owned_gerror_callback { |err| value = err }
    _(value.message).must_equal 'regression test owned error'
  end

  it 'has a working function #test_return_allow_none' do
    skip_below '1.47.1'
    result = Regress.test_return_allow_none
    _(result).must_be_nil
  end

  it 'has a working function #test_return_nullable' do
    skip_below '1.47.1'
    result = Regress.test_return_nullable
    _(result).must_be_nil
  end

  it 'has a working function #test_short' do
    result = Regress.test_short 23
    assert_equal 23, result
  end

  it 'has a working function #test_simple_boxed_a_const_return' do
    result = Regress.test_simple_boxed_a_const_return
    assert_equal [5, 6, 7.0], [result.some_int, result.some_int8, result.some_double]
  end

  it 'has a working function #test_simple_callback' do
    a = 0
    Regress.test_simple_callback { a = 1 }
    assert_equal 1, a
  end

  it 'has a working function #test_size' do
    assert_equal 2354, Regress.test_size(2354)
  end

  it 'has a working function #test_ssize' do
    assert_equal(-2_000_000, Regress.test_ssize(-2_000_000))
  end

  it 'has a working function #test_struct_a_parse' do
    a = Regress.test_struct_a_parse('this string is actually ignored')
    _(a).must_be_instance_of Regress::TestStructA
    _(a.some_int).must_equal 23
  end

  it 'has a working function #test_strv_in' do
    assert_equal true, Regress.test_strv_in(%w(1 2 3))
  end

  it 'has a working function #test_strv_in_gvalue' do
    arr = Regress.test_strv_in_gvalue
    _(arr).must_be :==, %w(one two three)
  end

  it 'has a working function #test_strv_out' do
    arr = Regress.test_strv_out
    _(arr).must_be :==, %w(thanks for all the fish)
  end

  it 'has a working function #test_strv_out_c' do
    arr = Regress.test_strv_out_c
    _(arr).must_be :==, %w(thanks for all the fish)
  end

  it 'has a working function #test_strv_out_container' do
    arr = Regress.test_strv_out_container
    _(arr).must_be :==, %w(1 2 3)
  end

  it 'has a working function #test_strv_outarg' do
    arr = Regress.test_strv_outarg
    _(arr).must_be :==, %w(1 2 3)
  end

  it 'has a working function #test_timet' do
    # Time rounded to seconds.
    t = Time.at(Time.now.to_i)
    result = Regress.test_timet(t.to_i)
    assert_equal t, Time.at(result)
  end

  it 'has a working function #test_torture_signature_0' do
    y, z, q = Regress.test_torture_signature_0 86, 'foo', 2
    assert_equal [86, 2 * 86, 3 + 2], [y, z, q]
  end

  it 'has a working function #test_torture_signature_1' do
    ret, y, z, q = Regress.test_torture_signature_1(-21, 'hello', 12)
    _([ret, y, z, q]).must_equal [true, -21, 2 * -21, 'hello'.length + 12]

    _(proc { Regress.test_torture_signature_1(-21, 'hello', 11) }).
      must_raise GirFFI::GLibError
  end

  it 'has a working function #test_torture_signature_2' do
    a = 1
    y, z, q = Regress.test_torture_signature_2 244, 'foofoo', 31 do |u|
      a = u
    end
    assert_equal [244, 2 * 244, 6 + 31], [y, z, q]
    _(a).must_be_instance_of Regress::TestCallbackUserData
  end

  it 'has a working function #test_uint' do
    assert_equal 31, Regress.test_uint(31)
  end

  it 'has a working function #test_uint16' do
    assert_equal 31, Regress.test_uint16(31)
  end

  it 'has a working function #test_uint32' do
    assert_equal 540_000, Regress.test_uint32(540_000)
  end

  it 'has a working function #test_uint64' do
    assert_equal 54_000_000_000_000, Regress.test_uint64(54_000_000_000_000)
  end

  it 'has a working function #test_uint8' do
    assert_equal 31, Regress.test_uint8(31)
  end

  it 'has a working function #test_ulong' do
    assert_equal 54_000_000_000_000, Regress.test_uint64(54_000_000_000_000)
  end

  it 'has a working function #test_unconventional_error_quark' do
    result = Regress.test_unconventional_error_quark
    _(GLib.quark_to_string(result)).must_equal 'regress-test-other-error'
  end

  it 'has a working function #test_unichar' do
    assert_equal 120, Regress.test_unichar(120)
    assert_equal 540_000, Regress.test_unichar(540_000)
  end

  it 'has a working function #test_unsigned_enum_param' do
    assert_equal 'value1', Regress.test_unsigned_enum_param(:value1)
    assert_equal 'value2', Regress.test_unsigned_enum_param(:value2)
  end

  it 'has a working function #test_ushort' do
    assert_equal 54_000_000, Regress.test_uint64(54_000_000)
  end

  it 'has a working function #test_utf8_const_in' do
    Regress.test_utf8_const_in("const \xe2\x99\xa5 utf8")
    pass
  end

  it 'has a working function #test_utf8_const_return' do
    result = Regress.test_utf8_const_return
    assert_equal "const \xe2\x99\xa5 utf8", result
  end

  it 'has a working function #test_utf8_inout' do
    result = Regress.test_utf8_inout "const \xe2\x99\xa5 utf8"
    assert_equal "nonconst \xe2\x99\xa5 utf8", result
  end

  it 'has a working function #test_utf8_nonconst_return' do
    result = Regress.test_utf8_nonconst_return
    assert_equal "nonconst \xe2\x99\xa5 utf8", result
  end

  it 'has a working function #test_utf8_null_in' do
    Regress.test_utf8_null_in nil
    pass
  end

  it 'has a working function #test_utf8_null_out' do
    _(Regress.test_utf8_null_out).must_be_nil
  end

  it 'has a working function #test_utf8_out' do
    result = Regress.test_utf8_out
    assert_equal "nonconst \xe2\x99\xa5 utf8", result
  end

  it 'has a working function #test_utf8_out_nonconst_return' do
    r, out = Regress.test_utf8_out_nonconst_return
    assert_equal %w(first second), [r, out]
  end

  it 'has a working function #test_utf8_out_out' do
    out0, out1 = Regress.test_utf8_out_nonconst_return
    assert_equal %w(first second), [out0, out1]
  end

  it 'has a working function #test_value_return' do
    result = Regress.test_value_return 3423
    _(result).must_equal 3423
  end

  it 'has a working function #test_versioning' do
    # TODO: Handle deprecation
    Regress.test_versioning
    pass
  end

  it 'raises an appropriate NoMethodError when a function is not found' do
    result = _(proc { Regress.this_method_does_not_exist }).must_raise(NoMethodError)
    _(result.message).must_match(/^undefined method `this_method_does_not_exist' (for Regress:Module|on Regress \(Module\))$/)
  end
end
