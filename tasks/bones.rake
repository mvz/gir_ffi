# The following code is copied straight from Bones 2.5.1
#
require 'pp'
require 'stringio'

module Bones

# Helper module that will pretty print OpenStruct objects. It is used mainly
# for debugging the Mr Bones project open struct.
#
module Debug

  # :stopdoc:
  KEY_LENGTH = 20
  VAR_LENGTH = 78 - 6 - KEY_LENGTH
  SEP = "\n" + ' '*(KEY_LENGTH+6)
  FMT = "  %-#{KEY_LENGTH}s => %s"
  # :startdoc:

  # Print all the keys for the given _ostruct_ to stdout. If a _prefix_ is
  # given, then the open struct keys will be prefixed with this string.
  #
  def self.show( ostruct, prefix = '' )
    sio = StringIO.new

    h = ostruct.instance_variable_get(:@table)
    h.keys.map {|k| k.to_s}.sort.each do |k|
      sio.seek 0
      sio.truncate 0
      next if k =~ %r/^_/o

      val = h[k.to_sym]
      if val.instance_of?(OpenStruct)
        self.show(val, prefix + k + '.')
      else
        PP.pp(val, sio, VAR_LENGTH)
        sio.seek 0
        val = sio.read
        val = val.split("\n").join(SEP)

        key = prefix + k
        key[(KEY_LENGTH-3)..-1] = '...' if key.length > KEY_LENGTH
        puts(FMT % [key, val])
      end
    end
  end

  # Print a single attribute from the given _ostruct_ to stdout. The
  # attributed is identified by the given _key_.
  #
  def self.show_attr( ostruct, key )
    sio = StringIO.new

    key = key.dup if key.frozen?
    val = key.split('.').inject(ostruct) {|os,k| os.send(k)}

    if val.instance_of?(OpenStruct)
      self.show(val, key + '.')
    else
      PP.pp(val, sio, VAR_LENGTH)
      sio.seek 0
      val = sio.read
      val = val.split("\n").join(SEP)

      key[(KEY_LENGTH-3)..-1] = '...' if key.length > KEY_LENGTH
      puts(FMT % [key, val])
    end
  end

end  # module Debug
end  # module Bones

namespace :bones do

  desc 'Show the PROJ open struct'
  task :debug do |t|
    atr = if t.application.top_level_tasks.length == 2
      t.application.top_level_tasks.pop
    end

    if atr then Bones::Debug.show_attr(PROJ, atr)
    else Bones::Debug.show PROJ end
  end

end  # namespace :bones

# EOF
