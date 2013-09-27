module GirFFI
  module BuilderHelper
    def const_defined_for parent, name
      if RUBY_VERSION < "1.9"
        parent.const_defined? name
      else
        parent.const_defined? name, false
      end
    end

    def optionally_define_constant parent, name
      if const_defined_for parent, name
        parent.const_get name
      else
        parent.const_set name, yield
      end
    end

    def get_or_define_class namespace, name, parent
      optionally_define_constant(namespace, name) { Class.new parent }
    end

    def get_or_define_module parent, name
      optionally_define_constant(parent, name) { Module.new }
    end
  end
end
