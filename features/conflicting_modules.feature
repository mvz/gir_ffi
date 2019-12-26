Feature: Conflicting modules

  Scenario: Loading gir_ffi after GLib has been defined
    Given a file named "conflict.rb" with:
      """
      module GLib
      end

      require 'gir_ffi'

      puts 'do not print me'
      """
    When I run `ruby conflict.rb`
    Then the output should contain "already defined"
    And the output should not contain "do not print me"
    And the exit status should be 1

  Scenario: Loading gir_ffi after GObject has been defined
    Given a file named "conflict.rb" with:
      """
      module GObject
      end

      require 'gir_ffi'

      puts 'do not print me'
      """
    When I run `ruby conflict.rb`
    Then the output should contain "already defined"
    And the output should not contain "do not print me"
    And the exit status should be 1

  Scenario: Setting up a module that was defined elsewhere
    Given a file named "conflict.rb" with:
      """
      module Cairo
      end

      require 'gir_ffi'

      GirFFI.setup :cairo

      puts 'do not print me'
      """
    When I run `ruby conflict.rb`
    Then the output should contain "already defined"
    And the output should not contain "do not print me"
    And the exit status should be 1
