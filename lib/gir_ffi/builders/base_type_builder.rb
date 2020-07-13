# frozen_string_literal: true

require "gir_ffi/builder_helper"

module GirFFI
  # Base class for type builders.
  class BaseTypeBuilder
    include BuilderHelper

    def initialize(info)
      @info = info
      @namespace = @info.namespace
      @classname = @info.safe_name
    end

    def build_class
      instantiate_class unless defined? @klass
      @klass
    end

    def instantiate_class
      setup_class unless already_set_up
    end

    attr_reader :info

    private

    def namespace_module
      @namespace_module ||= Builder.build_module @namespace
    end

    def lib
      @lib ||= namespace_module::Lib
    end

    def setup_constants
      optionally_define_constant(klass, :GIR_INFO) { info }
      klass.const_set :GIR_FFI_BUILDER, self
    end

    def already_set_up
      klass.const_defined? :GIR_FFI_BUILDER, false
    end

    def gir
      @gir ||= GObjectIntrospection::IRepository.default
    end
  end
end
