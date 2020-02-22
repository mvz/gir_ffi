# frozen_string_literal: true

require "gir_ffi_test_helper"

describe GirFFI::MethodStubber do
  describe "#method_stub" do
    let(:stubber) { GirFFI::MethodStubber.new(method_info) }
    let(:result) { stubber.method_stub }

    describe "for a regular method" do
      let(:method_info) do
        get_method_introspection_data("Regress", "TestObj", "instance_method")
      end

      it "creates a method stub" do
        _(result).must_equal <<~STUB
          def instance_method *args, &block
            setup_and_call "instance_method", args, &block
          end
        STUB
      end
    end

    describe "for a static method" do
      let(:method_info) do
        get_method_introspection_data("Regress", "TestObj", "static_method")
      end

      it "creates a class method stub" do
        _(result).must_equal <<~STUB
          def self.static_method *args, &block
            setup_and_call "static_method", args, &block
          end
        STUB
      end
    end

    describe "for a module function" do
      let(:method_info) do
        get_introspection_data("Regress", "test_int")
      end

      it "creates a module method stub" do
        _(result).must_equal <<~STUB
          def self.test_int *args, &block
            setup_and_call "test_int", args, &block
          end
        STUB
      end
    end

    describe "for a method with an empty name" do
      let(:method_info) do
        get_method_introspection_data("Regress", "TestObj", "instance_method")
      end

      it "creates a method stub with a safe name that sets up the unsafe method" do
        allow(method_info).to receive(:name).and_return ""
        _(result).must_equal <<~STUB
          def _ *args, &block
            setup_and_call "", args, &block
          end
        STUB
      end
    end
  end
end
