module Gtk
  _setup_method "init"

  def self.init_with_auto_argv
    my_args = init_without_auto_argv [$0, *ARGV]
    my_args.shift
    ARGV.replace my_args
  end
  class << self
    alias init_without_auto_argv init
    alias init init_with_auto_argv
  end
end

Gtk.class_eval do
end

