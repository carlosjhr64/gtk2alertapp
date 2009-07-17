# $Date: 2009/05/29 17:51:04 $
require 'rubygems'
require 'cronedit'

module My
  @@active = Hash.new(true)
  def self.cron_active
    @@active
  end

  @@last_id = nil
  def self.last_id_succ
    @@last_id = @@last_id.succ
  end
  def self.last_id
    @@last_id
  end
  def self.last_id=(value)
    @@last_id = value
  end

  @@crontab = nil
  def self.crontab=(value)
    @@crontab = value
    last_id = My.crontab.list.keys.sort.last
    My.last_id = (last_id)? last_id: Configuration::INITKEY
  end
  def self.crontab
    @@crontab
  end

  def self.common(obj, pack, width=nil, font=Configuration::FONT[:normal])
    obj.width_request = width if width
    obj.modify_font(font)
    pack.pack_start( obj, false, false, Configuration::GUI[:padding] )
  end

class CheckButton < Gtk::CheckButton
  def initialize(pack, active=true, width=nil)
    super()
    My.common(self, pack, width)
    self.active = active
  end
end

class Label < Gtk::Label
  def initialize(text, pack, width=nil, font=Configuration::FONT[:normal])
    super(text)
    My.common(self, pack, width, font)
    self.wrap = false
    self.justify = Gtk::JUSTIFY_LEFT
  end
end

class SpinButton < Gtk::SpinButton
  def show
    super
     @label.show
  end
  def hide
    super
     @label.hide
  end
  def label=(value)
    @label.text = value
  end
  def initialize(text, pack, max=60, min=0, width=Configuration::SPIN_BUTTON_WIDTH)
    super(min,max,1)
    @label = Label.new(text, pack)
    My.common(self, pack, width)
  end
end

class CheckSpinButton < Gtk::SpinButton
  def show
    super
     @check_button.show
     @label.show
  end
  def hide
    super
     @check_button.hide
     @label.hide
  end
  def initialize(text, pack, max=60, min=0, width=Configuration::SPIN_BUTTON_WIDTH)
    super(min,max,1)
    @check_button = CheckButton.new(pack)
    @label = Label.new(text, pack)
    My.common(self, pack, width)
  end

  def active?
    @check_button.active?
  end
end

class ComboBox < Gtk::ComboBox
  def initialize(list, pack, width=nil)
    super()
    My.common(self, pack, width)
    list.each{|t| self.append_text(t)}
  end
end

class CronEntryRow
  def initialize(pack, width=nil)
    hbox = Gtk::HBox.new
    now = Time.now
    @minute = CheckSpinButton.new('Minute',hbox)
    @minute.value = now.min
    @hour = CheckSpinButton.new('Hour', hbox, 23)
    @hour.value = now.hour
    @day = CheckSpinButton.new('Day', hbox, 31, 1)
    @day.value = now.day
    @month = CheckSpinButton.new('Month', hbox, 12, 1)
    @month.value = now.mon
    @wday = CheckSpinButton.new('Day Of Week', hbox, 7)
    @wday.value = now.wday
    pack.pack_start(hbox, false, false, Configuration::GUI[:padding])
  end

  def wday=(value)
    @wday.value = value
  end
  def wday
    @wday.value
  end

  def day=(value)
    @day.value = value
  end
  def day
    @day.value
  end

  def month=(value)
    @month.value = value
  end
  def month
    @month.value
  end

  def values
    return [
	(@minute.active?)?	@minute.value.to_i	: '*',
	(@hour.active?)?	@hour.value.to_i	: '*',	
	(@day.active?)?		@day.value.to_i		: '*',
	(@month.active?)?	@month.value.to_i	: '*',
	(@wday.active?)?	@wday.value.to_i	: '*'
	]
  end
end

class Entry < Gtk::Entry
  def hide
    super
    @label.hide
  end
  def show
    super
    @label.show
  end
  def label=(text)
    @label.text = text
  end
  def initialize(text, pack, width=nil)
    super()
    @label = Label.new(text, pack)
    My.common(self, pack, width)
  end
end

class CheckBox < Gtk::CheckButton
  def initialize(pack, width=nil)
    super()
    My.common(self,pack)
  end
end

class CronCommandRow
  def initialize(list, pack, width=nil)
    hbox = Gtk::HBox.new
    Label.new('Action:', hbox)
    @command = ComboBox.new(list, hbox)
    @command.signal_connect('changed'){
      # 0. Menu's text
      # 1. command <--check entry/file>
      # 2. check
      # 3. entry
      # 4. quoted?
      # 5. file
      presets = Configuration::PRESETS[@command.active]
      # Entry/message
      if presets[3] then
        @message.label = presets[3]
        @message.text = ''
        @message.show
      else
        @message.hide
      end
      # File chooser
      if presets[5] then
        @file_chooser.show
      else
        @file_chooser.hide
      end
      # Option/checked
      if presets[2] then
        @option.label = presets[2]
        @option.show
      else
        @option.hide
      end
    }
    @option = CheckBox.new(hbox)
    @message = Entry.new('', hbox)
    @file_chooser = Gtk::FileChooserButton.new('Select a file', Gtk::FileChooser::ACTION_OPEN)
    hbox.pack_start(@file_chooser, false, false, Configuration::GUI[:padding])
    @file_chooser.signal_connect('file-set'){ @message.text = @file_chooser.filename }
    pack.pack_start( hbox, false, false, Configuration::GUI[:padding] )
  end

  def hack
    # barely perceptible race condition hack to have window.show_all run before this next line. :(
    Thread.new{ sleep(0.125); @command.active = 0 }
  end

  def value
    i = @command.active
    presets = Configuration::PRESETS[i]
    # 0. Menu's text
    # 1. command <--check entry/file>
    # 2. check
    # 3. entry
    # 4. quoted?
    # 5. file

    # command
    text = presets[1]
    # option/checked
    text += ' ' + presets[2] if presets[2] && @option.active?
    # if message or file
    if presets[3] || presets[5] then
      # quoted? 'message': message
      text += (presets[4])? " '" + @message.text.gsub(/'/,"\\'") + "'": ' ' + @message.text
    end

    return text
  end
end

class Button < Gtk::Button
  def modify_font(font)
    self.child.modify_font(font)
  end
  def initialize(text, pack, width=nil)
    super(text)
    My.common(self, pack, nil)
  end
end

class CronLine < Gtk::HBox
  def initialize(id, values, command, pack, width=nil)
    super()
    My.common(self, pack, width)
    check = CheckButton.new(self, My.cron_active[id])
    check.signal_connect('clicked'){ My.cron_active[id] = check.active? }
    delete = Button.new('Delete', self)
    delete.signal_connect('clicked'){
      pack.remove(self)
      My.crontab.remove id
      My.crontab.commit
      self.destroy
    }
    test = Button.new('Test', self)
    test.signal_connect('clicked'){ system("#{command} &") }
    Label.new(values + '  ' + command, self)
    My.crontab.add id, values + ' ' + command
    My.crontab.commit
  end
end

class CronList
  def initialize(entry, command, pack, width=nil)
    hbox = Gtk::HBox.new
    button = Button.new('Add', hbox)
    pack.pack_start( hbox, false, false, Configuration::GUI[:padding] )
    button.signal_connect('clicked'){
      id = My.last_id_succ
      cl = CronLine.new(id, entry.values.join(' '), command.value, pack)
      cl.show_all
    }
    My.crontab.list.each {|id,values_command|
      if values_command=~/\s*(\S+\s+\S+\s+\S+\s+\S+\s+\S+)\s+(\S.*)$/ then
        CronLine.new(id, $1, $2, pack)
      end
    }
  end
end

class CalendarRow
  attr_accessor :entry

  def initialize(pack, width=nil)
    hbox = Gtk::HBox.new

    calendar = Gtk::Calendar.new()
    hbox.pack_start( calendar, false, false, Configuration::GUI[:padding] )
    calendar.signal_connect('day-selected'){
      @entry.day = calendar.day
      @entry.wday = Date.new( calendar.year, calendar.month + 1, calendar.day ).wday
    }
    calendar.signal_connect('month-changed'){
      @entry.month = calendar.month + 1
      @entry.wday = Date.new( calendar.year, calendar.month + 1, calendar.day ).wday
    }

    strftime = "%A,\n%B %d %Y,\n%I:%M:%S %p"
    time = Label.new(Time.now.strftime(strftime), hbox, nil, Configuration::FONT[:large])
    Thread.new {
      while true do
        sleep(1.0)
        time.text = Time.now.strftime(strftime)
      end
    }

    pack.pack_start( hbox, false, false, Configuration::GUI[:padding] )
  end
end
end
