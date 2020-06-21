Feature: Loading dependencies
  Setting up a module will set up its dependencies as well.

  Scenario: Setting up a module sets up its dependencies as well
    Given a file named "dependencies.rb" with:
      """
      require 'gir_ffi'

      puts "Atk exists before: #{Object.const_defined?(:Atk)}"
      GirFFI.setup :Gtk
      puts "Atk exists after: #{Object.const_defined?(:Atk)}"
      """
    When I run `ruby dependencies.rb`
    Then the output should contain exactly:
      """
      Atk exists before: false
      Atk exists after: true
      """
