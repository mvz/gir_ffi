$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')
require 'ffi'
require 'girepository'

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
      s << "\n FIELDS: " << fields.map {|f| f.name}.join(", ") if n_fields > 0
      s << "\n METHODS: " << methods.map {|m| m.name}.join(", ") if n_methods > 0
      s
    end
  end

  class ICallableInfo
    def to_s
      s = super
      s << ", caller owns #{caller_owns}"
      s << ", may return null" if may_return_null?
      s << "\n ARGS: " << args.map {|e| e.name}.join(", ") if n_args > 0
      s
    end
  end

  class IFunctionInfo
    def to_s
      s = super
      f = flags
      s << ", symbol = #{symbol}"
      s << ", IS_METHOD" if f & (1 << 0) != 0
      s << ", IS_CONSTRUCTOR" if f & (1 << 1) != 0
      s << ", IS_GETTER" if f & (1 << 2) != 0
      s << ", IS_SETTER" if f & (1 << 3) != 0
      s << ", WRAPS_VFUNC" if f & (1 << 4) != 0
      s << ", THROWS" if f & (1 << 5) != 0
      s
    end
    def generate
      f = flags
      s = "  # #{symbol}"
      s << ", IS_METHOD" if f & (1 << 0) != 0
      s << ", IS_CONSTRUCTOR" if f & (1 << 1) != 0
      s << ", IS_GETTER" if f & (1 << 2) != 0
      s << ", IS_SETTER" if f & (1 << 3) != 0
      s << ", WRAPS_VFUNC" if f & (1 << 4) != 0
      s << ", THROWS" if f & (1 << 5) != 0
      rubyname = case name
		 when /^get_(.*)/: $~[1]
		 when /^set_(.*)/: "#{$~[1]}="
		 else name
		 end

      s << "\n  def #{rubyname}"
      s << "\n  end"
      s
    end
  end

  class IObjectInfo
    def to_s
      s = super
      s << ", type_name: #{type_name}, type_init: #{type_init}, abstract: #{abstract?}"
      s << "\n\tInterfaces: " << interfaces.map {|e| e.name}.join(", ") if n_interfaces > 0
      fields.each {|e| s << "\nFIELD for #{self.name}: #{e}"} if n_fields > 0
      s << "\n\tProperties: " << properties.map {|e| e.name}.join(", ") if n_properties > 0
      s << "\n\tSignals: " << signals.map {|e| e.name}.join(", ") if n_signals > 0
      s << "\n\tVFuncs: " << vfuncs.map {|e| e.name}.join(", ") if n_vfuncs > 0
      s << "\n\tConstants: " << constants.map {|e| e.name}.join(", ") if n_constants > 0
      methods.each {|e| s << "\nMETHOD for #{self.name}: #{e}"} if n_methods > 0
      s
    end
    def generate
      s = "class #{namespace}::#{name}"
      s << "\n  # type_name: #{type_name}, type_init: #{type_init}, abstract: #{abstract?}"
      s << "\n  # Interfaces: " << interfaces.map {|e| e.name}.join(", ") if n_interfaces > 0
      fields.each {|e| s << "\n  # FIELD: #{e}"} if n_fields > 0
      s << "\n  # Properties: " << properties.map {|e| e.name}.join(", ") if n_properties > 0
      s << "\n  # Signals: " << signals.map {|e| e.name}.join(", ") if n_signals > 0
      s << "\n  # VFuncs: " << vfuncs.map {|e| e.name}.join(", ") if n_vfuncs > 0
      s << "\n  # Constants: " << constants.map {|e| e.name}.join(", ") if n_constants > 0
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
    puts gir.find_by_name 'GObject', 'Object'
  end
end

Main.run
