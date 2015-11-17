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

  describe 'Annotation::Object' do
    it 'has a working method #allow_none' do
      skip 'Needs testing'
    end
    it 'has a working method #calleeowns' do
      skip 'Needs testing'
    end
    it 'has a working method #calleesowns' do
      skip 'Needs testing'
    end
    it 'has a working method #compute_sum' do
      skip 'Needs testing'
    end
    it 'has a working method #compute_sum_n' do
      skip 'Needs testing'
    end
    it 'has a working method #compute_sum_nz' do
      skip 'Needs testing'
    end
    it 'has a working method #create_object' do
      skip 'Needs testing'
    end
    it 'has a working method #do_not_use' do
      skip 'Needs testing'
    end
    it 'has a working method #extra_annos' do
      skip 'Needs testing'
    end
    it 'has a working method #foreach' do
      skip 'Needs testing'
    end
    it 'has a working method #get_hash' do
      skip 'Needs testing'
    end
    it 'has a working method #get_objects' do
      skip 'Needs testing'
    end
    it 'has a working method #get_strings' do
      skip 'Needs testing'
    end
    it 'has a working method #hidden_self' do
      skip 'Needs testing'
    end
    it 'has a working method #in' do
      skip 'Needs testing'
    end
    it 'has a working method #inout' do
      skip 'Needs testing'
    end
    it 'has a working method #inout2' do
      skip 'Needs testing'
    end
    it 'has a working method #inout3' do
      skip 'Needs testing'
    end
    it 'has a working method #method' do
      skip 'Needs testing'
    end
    it 'has a working method #notrans' do
      skip 'Needs testing'
    end
    it 'has a working method #out' do
      skip 'Needs testing'
    end
    it 'has a working method #parse_args' do
      skip 'Needs testing'
    end
    it 'has a working method #set_data' do
      skip 'Needs testing'
    end
    it 'has a working method #set_data2' do
      skip 'Needs testing'
    end
    it 'has a working method #set_data3' do
      skip 'Needs testing'
    end
    it 'has a working method #string_out' do
      skip 'Needs testing'
    end
    it 'has a working method #use_buffer' do
      skip 'Needs testing'
    end
    it 'has a working method #watch_full' do
      skip 'Needs testing'
    end
    it 'has a working method #with_voidp' do
      skip 'Needs testing'
    end
    describe "its 'function-property' property" do
      it 'can be retrieved with #get_property' do
        skip 'Needs testing'
      end
      it 'can be retrieved with #function_property' do
        skip 'Needs testing'
      end
      it 'can be set with #set_property' do
        skip 'Needs testing'
      end
      it 'can be set with #function_property=' do
        skip 'Needs testing'
      end
    end
    describe "its 'string-property' property" do
      it 'can be retrieved with #get_property' do
        skip 'Needs testing'
      end
      it 'can be retrieved with #string_property' do
        skip 'Needs testing'
      end
      it 'can be set with #set_property' do
        skip 'Needs testing'
      end
      it 'can be set with #string_property=' do
        skip 'Needs testing'
      end
    end
    describe "its 'tab-property' property" do
      it 'can be retrieved with #get_property' do
        skip 'Needs testing'
      end
      it 'can be retrieved with #tab_property' do
        skip 'Needs testing'
      end
      it 'can be set with #set_property' do
        skip 'Needs testing'
      end
      it 'can be set with #tab_property=' do
        skip 'Needs testing'
      end
    end
    it "handles the 'attribute-signal' signal" do
      skip 'Needs testing'
    end
    it "handles the 'doc-empty-arg-parsing' signal" do
      skip 'Needs testing'
    end
    it "handles the 'list-signal' signal" do
      skip 'Needs testing'
    end
    it "handles the 'string-signal' signal" do
      skip 'Needs testing'
    end
  end
  describe 'Annotation::Struct' do
    it 'has a writable field objects' do
      skip 'Needs testing'
    end
  end
  it 'has a working function #attribute_func' do
    skip 'Needs testing'
  end
  it 'has a working function #custom_destroy' do
    skip 'Needs testing'
  end
  it 'has a working function #get_source_file' do
    skip 'Needs testing'
  end
  it 'has a working function #init' do
    skip 'Needs testing'
  end
  it 'has a working function #invalid_regress_annotation' do
    skip 'Needs testing'
  end
  it 'has a working function #ptr_array' do
    skip 'Needs testing'
  end
  it 'has a working function #return_array' do
    skip 'Needs testing'
  end
  it 'has a working function #return_filename' do
    skip 'Needs testing'
  end
  it 'has a working function #set_source_file' do
    skip 'Needs testing'
  end
  it 'has a working function #space_after_comment_bug631690' do
    skip 'Needs testing'
  end
  it 'has a working function #string_array_length' do
    skip 'Needs testing'
  end
  it 'has a working function #string_zero_terminated' do
    skip 'Needs testing'
  end
  it 'has a working function #string_zero_terminated_out' do
    skip 'Needs testing'
  end
  it 'has a working function #test_parsing_bug630862' do
    skip 'Needs testing'
  end
  it 'has a working function #transfer_floating' do
    skip 'Needs testing'
  end
  it 'has a working function #versioned' do
    skip 'Needs testing'
  end
end

