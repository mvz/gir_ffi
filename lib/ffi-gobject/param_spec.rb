# frozen_string_literal: true

GObject.load_class :ParamSpec

module GObject
  # Overrides for GParamSpec, GObject's base class for parameter specifications.
  class ParamSpec
    def ref
      Lib.g_param_spec_ref self
      self
    end

    def accessor_name
      get_name.tr('-', '_')
    end
  end
end
