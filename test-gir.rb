$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')
require 'ffi'
require 'girffi'

class Symbol
  def to_proc
    Proc.new {|o| o.send(self)}
  end
end

module GirFFI
  class IBaseInfo
    def to_s
      s = "#{type} #{name}"
      s << ", DEPRECATED" if deprecated? 
      s
    end
  end

  class IStructInfo
    def to_s
      s = super
      s << ", size = #{size}, alignment = #{alignment}"
      s << ", is #{'not ' unless gtype_struct?}a gtype struct"
      s << ", fields: #{n_fields}, methods: #{n_methods}"

      fields.each {|f| s << "\n FIELD: #{f}"}

      s << "\n METHODS: " << methods.map(&:name).join(", ") if n_methods > 0
      s
    end
  end

  class ICallableInfo
    def to_s
      s = super
      s << ", caller owns #{caller_owns}"
      s << ", may return null" if may_return_null?
      s << "\n RETURN TYPE: " << return_type.to_s
      args.each {|e| s << "\n ARG: #{e}"}
      s
    end
  end

  class IArgInfo
    def to_s
      "#{self.type} #{self.name}, #{self.direction}, #{self.return_value?}"
    end
  end

  class IFieldInfo
    def to_s
      "#{self.type} #{self.name}, offset=#{self.offset}, size=#{self.size}, flags=#{self.flags}"
    end
  end

  class IFunctionInfo
    def to_s
      s = super
      f = flags
      s << "\n Function details: symbol = #{symbol}"
      s << ", is method" if f & (1 << 0) != 0
      s << ", is constructor" if f & (1 << 1) != 0
      s << ", is getter" if f & (1 << 2) != 0
      s << ", is setter" if f & (1 << 3) != 0
      s << ", wraps vfunc" if f & (1 << 4) != 0
      s << ", throws" if f & (1 << 5) != 0
      s
    end

    def generate
      f = flags
      s = "\n  # #{symbol}"
      s << ", is_method" if f & (1 << 0) != 0
      s << ", is_constructor" if f & (1 << 1) != 0
      s << ", is_getter" if f & (1 << 2) != 0
      s << ", is_setter" if f & (1 << 3) != 0
      s << ", wraps_vfunc" if f & (1 << 4) != 0
      s << ", throws" if f & (1 << 5) != 0

      #aliases = []

      rt = return_type
      s << "\n  def #{name}"
      s << " " << args.map(&:name).join(", ") if n_args > 0
      s << "\n    "
      s << "Lib.#{symbol} " + (["@gobj"] + args.map(&:name)).join(", ")
      s << "\n  end"
      #aliases.each {|a| s << "\n  alias #{a} #{nm}"}
      
      s
    end

    def short_name
      # FIXME: Think about getter and setter method names later.
#      # setter: 1 arg, no return type
#      if name =~ /^get_(.*)/
#	aliases << $~[1]
#      when /^set_(.*)/:
#	aliases << "#{$~[1]}="
#      when /^is_(.*)/:
#	aliases << $~[1]
#      end
    end

  end

  class IObjectInfo
    def to_s
      s = super
      s << ", type_name: #{type_name}, type_init: #{type_init}, abstract: #{abstract?}"
      s << "\n\tInterfaces: " << interfaces.map(&:name).join(", ") if n_interfaces > 0
      fields.each {|e| s << "\nFIELD for #{self.name}: #{e}"}
      s << "\n\tProperties: " << properties.map(&:name).join(", ") if n_properties > 0
      s << "\n\tSignals: " << signals.map(&:name).join(", ") if n_signals > 0
      s << "\n\tVFuncs: " << vfuncs.map(&:name).join(", ") if n_vfuncs > 0
      s << "\n\tConstants: " << constants.map(&:name).join(", ") if n_constants > 0
      methods.each {|e| s << "\nMETHOD for #{self.name}: #{e}"}
      signals.each {|e| s << "\nSIGNAL for #{self.name}: #{e}"}
      s
    end

    def generate
      s = "class #{namespace}::#{name}"
      if parent
	s << " < #{parent.namespace}::#{parent.name}"
      end
      s << "\n  # type_name: #{type_name}, type_init: #{type_init}, abstract: #{abstract?}"
      s << "\n  # Interfaces: " << interfaces.map(&:name).join(", ") if n_interfaces > 0
      fields.each {|e| s << "\n  # FIELD: #{e}"}
      s << "\n  # Properties: " << properties.map(&:name).join(", ") if n_properties > 0
      s << "\n  # Signals: " << signals.map(&:name).join(", ") if n_signals > 0
      s << "\n  # VFuncs: " << vfuncs.map(&:name).join(", ") if n_vfuncs > 0
      s << "\n  # Constants: " << constants.map(&:name).join(", ") if n_constants > 0
      methods.each {|e| s << "\n" << e.generate}
      s << "\nend"
      s
    end
  end

  class ITypeInfo
    def to_s
      s = "TYPE: "
      s << "pointer to " if pointer?
      s << GirFFI::IRepository.type_tag_to_string(tag)
      if tag == :interface
	s << ": " << "#{interface.namespace}::#{interface.name}"
      end
      s
    end
  end
end

class Main
  def initialize
    @gir = GirFFI::IRepository.default
  end

  def infos_for lib, object = nil
    @gir.require lib, nil
    if object.nil?
      n = @gir.n_infos lib
      puts "Infos for #{lib}: #{n}"
      (0..(n-1)).each do |i|
	info = @gir.info lib, i
	puts info #if info.type == :OBJECT
      end
    else
      go = @gir.find_by_name lib, object
      puts go
      puts go.generate
    end
  end

  def run
    #infos_for 'GIRepository' #, 'IObjectInfo'
    infos_for 'Everything' #, 'Window'
    #infos_for 'GObject', 'Object'
  end
end

Main.new.run
