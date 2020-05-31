# frozen_string_literal: true

SimpleCov.start do
  add_group "Main", "lib"
  add_group "Tests", "test"
  add_group "Cuke support", "features"
  enable_coverage :branch
end
