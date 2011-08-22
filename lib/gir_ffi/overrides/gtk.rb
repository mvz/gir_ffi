module GirFFI
  module Overrides
    module Gtk

      def self.included(base)
	base._setup_method "init"
	base.extend ClassMethods
	base.class_eval do

	  class << self
	    alias init_without_auto_argv init
	    alias init init_with_auto_argv
	  end

	end
      end

      module ClassMethods

	def init_with_auto_argv
	  my_args = init_without_auto_argv [$0, *ARGV]
	  my_args.shift
	  ARGV.replace my_args
	end

      end
    end
  end
end
