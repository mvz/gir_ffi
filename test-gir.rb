$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')
require 'ffi'
require 'girepository'

class Symbol
  def to_proc
    Proc.new {|o| o.send(self)}
  end
end

module GIRepository
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
      s << "\n FIELDS: " << fields.map(&:name).join(", ") if n_fields > 0
      s << "\n METHODS: " << methods.map(&:name).join(", ") if n_methods > 0
      s
    end
  end

  class ICallableInfo
    def to_s
      s = super
      s << ", caller owns #{caller_owns}"
      s << ", may return null" if may_return_null?
      s << "\n ARGS: " << args.map(&:name).join(", ") if n_args > 0
      s
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

      aliases = []
      case name
      when /^get_(.*)/:
	aliases << $~[1]
      when /^set_(.*)/:
	aliases << "#{$~[1]}="
	aliases << name
      when /^is_(.*)/:
	aliases << $~[1]
	aliases << name
      else
	aliases << name
      end

      nm = aliases.shift
      s << "\n  def #{nm}"
      s << " " << args.map(&:name).join(", ") if n_args > 0
      s << "\n  end"
      aliases.each {|a| s << "\n  alias #{a} #{nm}"}
      
      s
    end
  end

  class IObjectInfo
    def to_s
      s = super
      s << ", type_name: #{type_name}, type_init: #{type_init}, abstract: #{abstract?}"
      s << "\n\tInterfaces: " << interfaces.map(&:name).join(", ") if n_interfaces > 0
      fields.each {|e| s << "\nFIELD for #{self.name}: #{e}"} if n_fields > 0
      s << "\n\tProperties: " << properties.map(&:name).join(", ") if n_properties > 0
      s << "\n\tSignals: " << signals.map(&:name).join(", ") if n_signals > 0
      s << "\n\tVFuncs: " << vfuncs.map(&:name).join(", ") if n_vfuncs > 0
      s << "\n\tConstants: " << constants.map(&:name).join(", ") if n_constants > 0
      methods.each {|e| s << "\nMETHOD for #{self.name}: #{e}"} if n_methods > 0
      s
    end
    def generate
      s = "class #{namespace}::#{name}"
      s << "\n  # type_name: #{type_name}, type_init: #{type_init}, abstract: #{abstract?}"
      s << "\n  # Interfaces: " << interfaces.map(&:name).join(", ") if n_interfaces > 0
      fields.each {|e| s << "\n  # FIELD: #{e}"} if n_fields > 0
      s << "\n  # Properties: " << properties.map(&:name).join(", ") if n_properties > 0
      s << "\n  # Signals: " << signals.map(&:name).join(", ") if n_signals > 0
      s << "\n  # VFuncs: " << vfuncs.map(&:name).join(", ") if n_vfuncs > 0
      s << "\n  # Constants: " << constants.map(&:name).join(", ") if n_constants > 0
      methods.each {|e| s << "\n" << e.generate} if n_methods > 0
      s << "\nend"
      s
    end
  end
end

module Main
  def self.infos_for gir, lib
    gir.require lib, nil
    n = gir.n_infos lib
    puts "Infos for #{lib}: #{n}"
    (0..(n-1)).each do |i|
      info = gir.info lib, i
      puts info if info.type == :OBJECT
    end
  end

  def self.run
    gir = GIRepository::IRepository.default
    #self.infos_for gir, 'Gtk'
    gir.require 'GObject', nil
    go = gir.find_by_name 'GObject', 'Object'
    puts go
    #puts go.generate
  end
end

Main.run
