# Regexp defined
# String defined
# Range defined
# [] defined
module Gtk2AlertApp
# Alerts is like a Hash
class Alerts < Hash
  # note parser is fault tolerant
  XPARSER = Regexp.new('^(#\s*)?(\w+)\s+([*.\d]+)\s+([*.\d]+)\s+([*.\d]+)\s+([*.\d]+)\s+([*.\d]+)\s+(\S.*)$')

  def self._map(md)
    # note parser is fault tolerant
    md[3..7].map{|part| (part=~/^\*/)? nil: ((part=~/(\d+)\.+(\d+)/)? Range.new($1.to_i,$2.to_i): part.to_i) }
  end

  def self._add_string(line)
    md = XPARSER.match(line)
    raise "Parse error, could not parse '#{line}'" if !md
    # name, flag, minute, hour, day, month, wday, command
    return [md[2], md[1].nil?, Alerts._map(md), md[8]]
  end

  def _add_string(line)
    name,*values = *Alerts._add_string(line)
    self[name] = values.flatten
  end

  def _add_array(line)
    raise "Expected 8 items in Array" if !(line.length == 8)
    name = line.shift
    self[name] = line
  end

  def add(line)
    klass = line.class
    raise "Type error, expected String or Array, but got #{klass}" if ![Array,String].include?(klass)
    (klass == String)? _add_string(line) : _add_array(line)
  end

  def self._entry(name,values)
    # Beware not to modify values, it is self[name].
    command = values.last
    flag = (values.first == true)? ' ': '#'
    "#{flag} #{name.ljust(20)} #{values[1..5].map{|value| (value.nil?)? '*': value }.join(' ')}\t#{command}"
  end

  def entry(name)
    return Alerts._entry(name,self[name])
  end


  def initialize
    super
  end
end
end
