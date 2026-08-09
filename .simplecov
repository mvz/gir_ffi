# frozen_string_literal: true

SimpleCov.configure do
  # Remove the "test_frameworks" filter
  clear_filters
  load_profile "bundler_filter"
  load_profile "hidden_filter"
  load_profile "root_filter"

  group "Main", "lib"
  group "Tests", "test"
  group "Cuke support", "features"

  enable_coverage :branch
end
