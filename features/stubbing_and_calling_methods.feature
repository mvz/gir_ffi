Feature: Stubbing and calling methods
  Methods are stubbed on the defining class, and set up when called

  Scenario: Setting up a struct class
    Given a file named "test.rb" with:
      """
      require "gir_ffi"
      GirFFI.setup :Gtk, "3.0"
      puts "Before: BindingSet exists: #{Gtk.const_defined? :BindingSet}"
      Gtk.load_class :BindingSet
      puts "After: BindingSet exists: #{Gtk.const_defined? :BindingSet}"
      struct = Gtk::BindingSet
      result = struct.instance_methods.include? :activate
      puts "Result: #{result}"
      """
    When I run `ruby test.rb`
    Then the output should contain exactly:
      """
      Before: BindingSet exists: false
      After: BindingSet exists: true
      Result: true
      """
