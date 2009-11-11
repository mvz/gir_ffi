require 'ffi'
require 'lib/girepository.rb'

module GIRepository
  class IBaseInfo
    def self.build_array_method elementname, plural = nil
      plural ||= "#{elementname}s"
      define_method "#{plural}" do
	(0..((send "n_#{plural}") - 1)).map do |i|
	  send elementname, i
	end
      end
    end

    def initialize gobj=nil
      raise "#{self.class} creation not implemeted" if gobj.nil?
      @gobj = gobj
    end
    def name; Lib.g_base_info_get_name @gobj; end
    def type; Lib.g_base_info_get_type @gobj; end
    def namespace; Lib.g_base_info_get_namespace @gobj; end
    def deprecated?; Lib.g_base_info_is_deprecated @gobj; end
    def to_s
      s = "#{type} #{name}"
      s << ", DEPRECATED" if deprecated? 
      s
    end
  end

  class IStructInfo < IBaseInfo
    def n_fields; Lib.g_struct_info_get_n_fields @gobj; end
    def field i; IFieldInfo.new(Lib.g_struct_info_get_field @gobj, i); end

    build_array_method :field

    def n_methods; Lib.g_struct_info_get_n_methods @gobj; end
    def method i; IFunctionInfo.new(Lib.g_struct_info_get_method @gobj, i); end

    build_array_method :method

    def find_method name; Lib.g_struct_info_find_method @gobj, name; end
    def size; Lib.g_struct_info_get_size @gobj; end
    def alignment; Lib.g_struct_info_get_alignment @gobj; end
    def gtype_struct?; Lib.g_struct_info_is_gtype_struct @gobj; end

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

  class IFunctionInfo < IBaseInfo
    def symbol; Lib.g_function_info_get_symbol @gobj; end
    def flags; Lib.g_function_info_get_flags @gobj; end

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
  end

  class IFieldInfo < IBaseInfo
  end

  class IInterfaceInfo < IBaseInfo
  end

  class IPropertyInfo < IBaseInfo
  end

  class ISignalInfo < IBaseInfo
  end

  class IConstantInfo < IBaseInfo
  end

  class IVFuncInfo < IBaseInfo
  end

  class IObjectInfo < IBaseInfo
    def type_name; Lib.g_object_info_get_type_name @gobj; end
    def type_init; Lib.g_object_info_get_type_init @gobj; end
    def abstract?; Lib.g_object_info_get_abstract @gobj; end
    def parent; IObjectInfo.new(Lib.g_object_info_get_parent @gobj); end

    def n_interfaces; Lib.g_object_info_get_n_interfaces @gobj; end
    def interface i; IInterfaceInfo.new(Lib.g_object_info_get_interface @gobj, i); end
    build_array_method :interface

    def n_fields; Lib.g_object_info_get_n_fields @gobj; end
    def field i; IFieldInfo.new(Lib.g_object_info_get_field @gobj, i); end
    build_array_method :field

    def n_properties; Lib.g_object_info_get_n_properties @gobj; end
    def property i; IPropertyInfo.new(Lib.g_object_info_get_property @gobj, i); end
    build_array_method :property, :properties

    def n_methods; Lib.g_object_info_get_n_methods @gobj; end
    def method i; IFunctionInfo.new(Lib.g_object_info_get_method @gobj, i); end
    def find_method; IFunctionInfo.new(Lib.g_object_info_find_method @gobj); end
    build_array_method :method

    def n_signals; Lib.g_object_info_get_n_signals @gobj; end
    def signal i; ISignalInfo.new(Lib.g_object_info_get_signal @gobj, i); end
    build_array_method :signal

    def n_vfuncs; Lib.g_object_info_get_n_vfuncs @gobj; end
    def vfunc i; IVFuncInfo.new(Lib.g_object_info_get_vfunc @gobj, i); end
    def find_vfunc; IVFuncInfo.new(Lib.g_object_info_find_vfunc @gobj); end
    build_array_method :vfunc

    def n_constants; Lib.g_object_info_get_n_constants @gobj; end
    def constant i; IConstantInfo.new(Lib.g_object_info_get_constant @gobj, i); end
    build_array_method :constant

    def class_struct; IStructInfo.new(Lib.g_object_info_get_class_struct @gobj); end

    def to_s
      s = super
      s << ", type_name: #{type_name}, type_init: #{type_init}, abstract: #{abstract?}"
      s << "\n\tInterfaces: " << interfaces.map {|e| e.name}.join(", ") if n_interfaces > 0
      s << "\n\tFields: " << fields.map {|e| e.name}.join(", ") if n_fields > 0
      s << "\n\tProperties: " << properties.map {|e| e.name}.join(", ") if n_properties > 0
      s << "\n\tMethods: " << methods.map {|e| e.name}.join(", ") if n_methods > 0
      s << "\n\tSignals: " << signals.map {|e| e.name}.join(", ") if n_signals > 0
      s << "\n\tVFuncs: " << vfuncs.map {|e| e.name}.join(", ") if n_vfuncs > 0
      s << "\n\tConstants: " << constants.map {|e| e.name}.join(", ") if n_constants > 0
      s
    end
  end
end

module Main
  def self.infos_for gir, lib
    gir.require lib, nil
    n = gir.get_n_infos lib
    puts "Infos for #{lib}: #{n}"
    (0..(n-1)).each do |i|
      info = gir.get_info lib, i
      puts info
    end
  end

  def self.run
    GIRepository::Helper::GType.init

    gir = GIRepository::IRepository.get_default
    self.infos_for gir, 'Gtk'
  end
end

Main.run
