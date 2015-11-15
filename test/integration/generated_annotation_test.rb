require 'gir_ffi_test_helper'

GirFFI.setup :Annotation

describe Annotation do
  describe 'Annotation::Bitfield' do
    it 'has the member :foo' do
      Annotation::Bitfield[:foo].must_equal 1
    end
    it 'has the member :bar' do
      Annotation::Bitfield[:bar].must_equal 2
    end
  end
  it 'has the constant CALCULATED_DEFINE' do
    Annotation::CALCULATED_DEFINE.must_equal 100
  end
  it 'has the constant CALCULATED_LARGE' do
    skip 'Constant is marked with the wrong type'
    Annotation::CALCULATED_LARGE.must_equal 10_000_000_000
  end
  it 'has the constant CALCULATED_LARGE_DIV' do
    Annotation::CALCULATED_LARGE_DIV.must_equal 1_000_000
  end
  describe 'Annotation::Fields' do
    let(:instance) { Annotation::Fields.new }

    it 'has a writable field field1' do
      instance.field1.must_equal 0
      instance.field1 = 42
      instance.field1.must_equal 42
    end

    it 'has a writable field arr' do
      instance.arr.must_equal nil
      instance.arr = [1, 2, 3]
      # TODO: len should be set automatically
      instance.len = 3
      instance.arr.to_a.must_equal [1, 2, 3]
      instance.len.must_equal 3
    end

    it 'has a writable field len' do
      skip 'len should not be set independently'
    end
  end

  # TODO: These need testing
  describe 'Annotation::Object' do
    it 'has a working method #allow_none' do
    end
    it 'has a working method #calleeowns' do
    end
    it 'has a working method #calleesowns' do
    end
    it 'has a working method #compute_sum' do
    end
    it 'has a working method #compute_sum_n' do
    end
    it 'has a working method #compute_sum_nz' do
    end
    it 'has a working method #create_object' do
    end
    it 'has a working method #do_not_use' do
    end
    it 'has a working method #extra_annos' do
    end
    it 'has a working method #foreach' do
    end
    it 'has a working method #get_hash' do
    end
    it 'has a working method #get_objects' do
    end
    it 'has a working method #get_strings' do
    end
    it 'has a working method #hidden_self' do
    end
    it 'has a working method #in' do
    end
    it 'has a working method #inout' do
    end
    it 'has a working method #inout2' do
    end
    it 'has a working method #inout3' do
    end
    it 'has a working method #method' do
    end
    it 'has a working method #notrans' do
    end
    it 'has a working method #out' do
    end
    it 'has a working method #parse_args' do
    end
    it 'has a working method #set_data' do
    end
    it 'has a working method #set_data2' do
    end
    it 'has a working method #set_data3' do
    end
    it 'has a working method #string_out' do
    end
    it 'has a working method #use_buffer' do
    end
    it 'has a working method #watch_full' do
    end
    it 'has a working method #with_voidp' do
    end
    describe "its 'function-property' property" do
      it 'can be retrieved with #get_property' do
      end
      it 'can be retrieved with #function_property' do
      end
      it 'can be set with #set_property' do
      end
      it 'can be set with #function_property=' do
      end
    end
    describe "its 'string-property' property" do
      it 'can be retrieved with #get_property' do
      end
      it 'can be retrieved with #string_property' do
      end
      it 'can be set with #set_property' do
      end
      it 'can be set with #string_property=' do
      end
    end
    describe "its 'tab-property' property" do
      it 'can be retrieved with #get_property' do
      end
      it 'can be retrieved with #tab_property' do
      end
      it 'can be set with #set_property' do
      end
      it 'can be set with #tab_property=' do
      end
    end
    it "handles the 'attribute-signal' signal" do
    end
    it "handles the 'doc-empty-arg-parsing' signal" do
    end
    it "handles the 'list-signal' signal" do
    end
    it "handles the 'string-signal' signal" do
    end
  end
  describe 'Annotation::Struct' do
    it 'has a writable field objects' do
    end
  end
  it 'has a working function #attribute_func' do
  end
  it 'has a working function #custom_destroy' do
  end
  it 'has a working function #get_source_file' do
  end
  it 'has a working function #init' do
  end
  it 'has a working function #invalid_regress_annotation' do
  end
  it 'has a working function #ptr_array' do
  end
  it 'has a working function #return_array' do
  end
  it 'has a working function #return_filename' do
  end
  it 'has a working function #set_source_file' do
  end
  it 'has a working function #space_after_comment_bug631690' do
  end
  it 'has a working function #string_array_length' do
  end
  it 'has a working function #string_zero_terminated' do
  end
  it 'has a working function #string_zero_terminated_out' do
  end
  it 'has a working function #test_parsing_bug630862' do
  end
  it 'has a working function #transfer_floating' do
  end
  it 'has a working function #versioned' do
  end
end

