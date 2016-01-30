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
  end
end
