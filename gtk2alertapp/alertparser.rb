module Gtk2AlertApp
class Alerts < Hash
  # note parser is fault tolerant
  XPARSER = Regexp.new('^(#\s*)?(\w+)\s+([*.\d]+)\s+([*.\d]+)\s+([*.\d]+)\s+([*.\d]+)\s+([*.\d]+)\s+(\S.*)$')

  def add(line)
    raise "Type error, expected String or Array, but got #{line.class}" if !(line.class == Array || line.class == String)
    if line.class == String then
      md = XPARSER.match(line)
      raise "Parse error, could not parse '#{line}'" if !md
      flag = md[1].nil?
      name = md[2]
      command = md[8]
      minute, hour, day, month, wday = md[3..7].map{|x|
        # note parser is fault tolerant
        (x=~/^\*/)? nil: ((x=~/(\d+)\.+(\d+)/)? Range.new($1.to_i,$2.to_i): x.to_i)
      }
      self[name] = [flag, minute, hour, day, month, wday, command]
    else
      raise "Expected 8 items in Array, got #{line.length}" if !(line.length == 8)
      name = line.shift
      self[name] = line
    end
  end

  def entry(name)
    v = self[name]
    command = v.last
    flag = v.first
    line = nil
    if flag then
      line = "  #{name}\t#{v[1..5].map{|x| (x.nil?)? '*': x}.join(' ')}\t#{command}"
    else
      line = "# #{name}\t#{v[1..5].map{|x| (x.nil?)? '*': x}.join(' ')}\t#{command}"
    end
    return line
  end


  def initialize
    super
  end
end
end
