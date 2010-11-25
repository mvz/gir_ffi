module GirFFI
  module BuilderHelper
    def self.const_defined_for parent, name
      if RUBY_VERSION < "1.9"
	parent.const_defined? name
      else
	parent.const_defined? name, false
      end
    end

    def self.optionally_define_constant parent, name
      unless const_defined_for parent, name
	parent.const_set name, yield
      end
      parent.const_get name
    end

  end
end
