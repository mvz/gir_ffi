require 'ffi-glib/list_instance_methods'
require 'ffi-glib/list_class_methods'

module GLib
  load_class :SList

  class SList
    attr_accessor :element_type
    include ListInstanceMethods
    extend ListClassMethods
    include Enumerable
  end
end
