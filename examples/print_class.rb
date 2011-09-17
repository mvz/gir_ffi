$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'gir_ffi'

# File activesupport/lib/active_support/inflector/methods.rb, line 48
def underscore(camel_cased_word)
  word = camel_cased_word.to_s.dup
  word.gsub!(/::/, '/')
  word.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
  word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
  word.tr!("-", "_")
  word.downcase!
  word
end

namespace = 'GObject'
GirFFI.setup namespace
modul = Kernel.const_get(namespace)

gir = GObjectIntrospection::IRepository.default
gir.require namespace, nil
infos = gir.infos namespace

main_file = File.open(File.join('.', "#{underscore(namespace)}.rb"), 'w')

main_file.write "module #{namespace}\n"

infos.each do |info|
  case info.info_type
  when :function
    fbuilder = GirFFI::Builder::Function.new info, modul::Lib
    main_file.write "\n"
    main_file.write fbuilder.generate
    main_file.write "\n"
  when :object
    main_file.write "class #{info.name} < #{info.parent.name}\n"
    info.get_methods.each do |minfo|
      main_file.write "\n"
      unless minfo.method?
        main_file.write "class << self\n"
      end
      if minfo.constructor?
        main_file.write "# This method is a constructor\n"
      end
      main_file.write "# @return [#{minfo.return_type.tag}]\n"

      fbuilder = GirFFI::Builder::Function.new minfo, modul::Lib
      main_file.write fbuilder.generate
      unless minfo.method?
        main_file.write "end\n"
      end
      main_file.write "\n"
    end
    main_file.write "end\n"
  else
    puts "#{info.info_type}: #{info.name}\n"
  end
end

main_file.write "end\n"
main_file.close

