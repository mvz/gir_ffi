# frozen_string_literal: true
module GirFFI
  # Represents a signal not found in the GIR, conforming, as needed, to the
  # interface of GObjectIntrospection::ISignalInfo.
  class UnintrospectableSignalInfo
    attr_reader :signal_id

    def initialize(signal_id)
      @signal_id = signal_id
    end

    def name
      GObject.signal_name signal_id
    end

    def wrap_in_closure(&block)
      GObject::RubyClosure.new(&block)
    end

    def arguments_to_gvalues(instance, arguments)
      param_gtypes = signal_query.param_types || []

      argument_gvalues = param_gtypes.zip(arguments).map do |gtype, arg|
        GObject::Value.for_gtype(gtype).tap { |it| it.set_value arg }
      end

      argument_gvalues.unshift GObject::Value.wrap_instance(instance)
    end

    def gvalue_for_return_value
      GObject::Value.for_gtype signal_query.return_type
    end

    private

    def signal_query
      @signal_query ||= GObject.signal_query signal_id
    end
  end
end
