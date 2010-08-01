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

    def self.get_or_define_module parent, name
      optionally_define_constant(parent, name) { Module.new }
    end

    def self.get_or_define_class namespace, name, parent
      BuilderHelper.optionally_define_constant namespace, name do
	if parent.nil?
	  klass = Class.new
	else
	  klass = Class.new parent
	end
      end
    end
  end
end
