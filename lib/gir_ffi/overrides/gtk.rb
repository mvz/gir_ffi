module GirFFI
  module Overrides
    module Gtk

      def self.included(base)
	GirFFI::Builder.setup_function "Gtk", "init"
	base.class_eval do

	  class << self

	    alias _base_init init

	    def init
	      (my_len, my_args) = _base_init ARGV.length + 1, [$0, *ARGV]
	      my_args.shift
	      ARGV.replace my_args
	    end

	    private :_base_init
	  end

	end
      end

    end
  end
end
