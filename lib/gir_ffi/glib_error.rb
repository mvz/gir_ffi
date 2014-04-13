module GirFFI
  # Exception class to be raised whenever an error is signaled through
  # GLib::Error.
  class GLibError < RuntimeError
    attr_reader :domain_quark
    attr_reader :code

    def initialize g_error
      @domain_quark = g_error.domain
      @code = g_error.code
      super g_error.message
    end

    def domain
      @domain ||= GLib.quark_to_string @domain_quark
    end
  end
end
