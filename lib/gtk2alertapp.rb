require 'date' # Date defined
# Gtk2AppLib defined
# Configuration defined
# Range defined
# Time defined
# Gtk defined in gtk2

module Gtk2AlertApp

class NameEntry < Gtk2AppLib::Widgets::Entry # NameEntry defined
  def initialize(pack)
    super(pack,'focus-out-event'){
      self.text = self.text.strip.gsub(/\W+/, '_')
      false
    }
  end
end

class AddButton # AddButton defined

  def initialize(pipe,alerts,pack)
    @entry_rows = nil # set later
    @add = Gtk2AppLib::Widgets::Button.new(*Configuration::ADD_BUTTON+[pack,'clicked']){|alert|
      name = alert.first.text.strip
      ok = true
      modifying = false
      if name.length == 0 then
        ok = false
        Gtk2AppLib::DIALOGS.quick_message(*Configuration::ALERT_NAME_ERROR)
      elsif alerts[name] then
        ok = Gtk2AppLib::DIALOGS.question?(*Configuration::OVERWRITE_VERIFY)
        modifying = ok
      end
      if ok then
        begin
          alerts.add( [name, alert[1].to_s, alert.last.text].join("\t") )
          pipe.puts "a #{alerts.entry(name)}"; pipe.flush; pipe.puts "s #{Configuration::ALERTS_DATA_FILE}"; pipe.flush
          @entry_rows.delete(name) if modifying
          @entry_rows.add(name, true) # add row to gui listing
          Gtk2AppLib::DIALOGS.quick_message(*Configuration::ALERT_ADDED)
        rescue
          $!.puts_bang!
          # anything for the gui TODO ?
        end
      end
    }
    @add.is = nil
  end

  def value=(v)
    @add.is = v
  end

  def entry_rows=(hook)
    @entry_rows = hook
  end
end

class CronCommandRow < Gtk2AppLib::Widgets::HBox # CronCommandRow defined

  def initialize(pipe,alerts,cron,pack)
    super(pack)
    @add = AddButton.new(pipe,alerts,self)
    @name = NameEntry.new(self)
    @add.value = [@name,cron,self]
    @option = @file_chooser = @message = @label = nil # for rus, defined later
    @command = Gtk2AppLib::Widgets::ComboBox.new(Configuration::PRESETS.map{|c| c[0]}, self, Configuration::COMBO_BOX, 'changed'){
      # 0. Menu's text
      # 1. command <--check entry/file>
      # 2. check
      # 3. entry
      # 4. quoted?
      # 5. filE
      presets = Configuration::PRESETS[@command.active]
      # Entry/message
      if presets[3] then
        @label.label = presets[3]
        @message.text = ''
        @label.show
        @message.show
      else
        @label.hide
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
    @option = Gtk2AppLib::Widgets::CheckButton.new('',Configuration::COMMAND_CHECK_BUTTON,self)
    @label = Gtk2AppLib::Widgets::Label.new(self,Configuration::COMMAND_LABEL)
    @message = Gtk2AppLib::Widgets::Entry.new(self,Configuration::COMMAND_ENTRY)
    @file_chooser = Gtk2AppLib::Widgets::FileChooserButton.new(*Configuration::SELECT_A_FILE+[self,'file-set']) { @message.text = @file_chooser.filename }
    @command.active = 0
  end

  def hide_init
    @label.hide
    @message.hide
    @file_chooser.hide
    @option.hide
  end

  def entry_rows=(hook)
    @add.entry_rows = hook
  end

  def text
    i = @command.active
    presets = Configuration::PRESETS[i]
    # 0. Menu's text
    # 1. command <--check entry/file>
    # 2. check
    # 3. entry
    # 4. quoted?
    # 5. file
    @message.text = @file_chooser.filename if presets[5] && (@message.text.strip == '')

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

class CronTab < Gtk2AppLib::Widgets::HBox # CronTab defined # CronTab defined

  def initialize(text, pack, max=59, min=0)
    super(pack)
    @check_button = Gtk2AppLib::Widgets::CheckButton.new(self, Configuration::CRON_TAB_CHECK_BUTTON)
    @label = Gtk2AppLib::Widgets::Label.new(text, self, Configuration::CRON_TAB_LABEL)
    @data2 = nil # for rus, defined later
    @data1 = Gtk2AppLib::Widgets::SpinButton.new(self,{:set_range=>[min,max]},Configuration::CRON_TAB_SPIN,'changed'){
      @data2.value = @data1.value
    }
    @data2 = Gtk2AppLib::Widgets::SpinButton.new(self,{:set_range=>[min,max]},Configuration::CRON_TAB_SPIN,'changed'){
      @data1.value = @data2.value if @data1.value > @data2.value
    }
  end

  def value=(v)
    if v.class == Range then
      @data1.value = v.begin
      @data2.value = v.end
    else
      @data1.value = v
      @data2.value = v
    end
  end

  def active=(v)
    @check_button.active = v
  end

  def active?
    @check_button.active?
  end

  def value
    ret = nil
    if @check_button.active? then
      ret = @data1.value.to_i
      ret2 = @data2.value.to_i
      if !(ret == ret2) then
        ret = (ret<ret2)? Range.new(ret,ret2): Range.new(ret2,ret)
      end
    end
    return ret
  end
end

class CronEntryRow < Gtk2AppLib::Widgets::VBox # CronEntryRow defined

  def initialize(cron, pack)
    super(pack)
    now = Time.now

    cron.minute = CronTab.new(Configuration::MINUTE,self)
    cron.minute.value = now.min

    cron.hour = CronTab.new(Configuration::HOUR, self, 23)
    cron.hour.value = now.hour

    cron.day = CronTab.new(Configuration::DAY, self, 31, 1)
    cron.day.value = now.day

    cron.month = CronTab.new(Configuration::MONTH, self, 12, 1)
    cron.month.value = now.mon

    cron.wday = CronTab.new(Configuration::WEEKDAY, self, 7)
    cron.wday.value = now.wday
  end
end

class Cron # Cron defined
  attr_accessor :minute, :hour, :day, :month, :wday
  def initialize
  end

  def to_s(spc=' ')
    return [
	(@minute.active?)?	@minute.value.to_s: '*',
	(@hour.active?)?	@hour.value.to_s: '*',	
	(@day.active?)?		@day.value.to_s: '*',
	(@month.active?)?	@month.value.to_s: '*',
	(@wday.active?)?	@wday.value.to_s: '*'
	].join(spc)
  end
end

class AlertEditor < Gtk2AppLib::Widgets::VBox

  def initialize(pipe, pack, alerts)
    super(pack)

    # Cron Editor
    hbox = Gtk2AppLib::Widgets::HBox.new(self)
    @cron = Cron.new
    @calendar = Gtk2AppLib::Widgets::Calendar.new(hbox, Configuration::CALENDAR, 'day-selected', 'month-changed'){|is,signal|
      if signal == 'day-selected' then
        @cron.day.value = is.day
        @cron.wday.value = Date.new( is.year, is.month + 1, is.day ).wday
      else
        @cron.month.value = is.month + 1
      end
      false
    }
    CronEntryRow.new(@cron, hbox)

    # Presets
    @ccr = CronCommandRow.new(pipe, alerts, @cron, self)

    # Command Editor
    hbox = Gtk2AppLib::Widgets::HBox.new(self)
    @add = AddButton.new(pipe,alerts,hbox)
    @name = NameEntry.new(hbox)
    @command = Gtk2AppLib::Widgets::Entry.new(hbox, Configuration::EDITOR_ENTRY)
    @add.value = [@name,@cron,@command]
  end

  def hide_init
    @ccr.hide_init
  end

  def entry_rows=(hook)
    @add.entry_rows = hook
    @ccr.entry_rows = hook
  end

  def name=(nme)
    @name.text = nme
  end

  def value=(alert)
    if alert[1] then
      @cron.minute.active = true
      @cron.minute.value=alert[1]
    else
      @cron.minute.active =false
    end
    if alert[2] then
      @cron.hour.active = true
      @cron.hour.value=alert[2]
    else
      @cron.hour.active =false
    end
    if alert[3] then
      @cron.day.active = true
      @cron.day.value=alert[3]
    else
      @cron.day.active =false
    end
    if alert[4] then
      @cron.month.active = true
      @cron.month.value=alert[4]
    else
      @cron.month.active =false
    end
    if alert[5] then
      @cron.wday.active = true
      @cron.wday.value=alert[5]
    else
      @cron.wday.active =false
    end
    @command.text = alert.last
  end
end

class DigitalClock < Gtk2AppLib::Widgets::Label
  def initialize(strftime, pack)
    tick =nil
    super(Time.now.strftime(strftime), pack,'destroy'){ Gtk.timeout_remove(tick) }
    tick = Gtk.timeout_add(1000){ self.text = Time.now.strftime(strftime) }
  end
end

class EntryRows < Gtk2AppLib::Widgets::VBox

  def initialize(pipe, alert_editor, alerts, pack)
    super(pack)
    @pipe = pipe			# pipe to alerts daemon
    @alert_editor = alert_editor	# hook to the alert editor
    @alerts = alerts			# the alerts hash/parser
    @rows = {}				# keeps a name/row map
  end

  def delete(name)
    if row = @rows[name] then
      self.remove(row)
      row.destroy
      @rows.delete(name)
    end
  end

  def add(name, reorder=false)
    hbox = Gtk2AppLib::Widgets::HBox.new(self) # create the new row to populate
    @rows[name] = hbox

    label = nil # set later
    # alerts[name] = [flag, minute, hour, day, month, wday, command]
    b0 = Gtk2AppLib::Widgets::CheckButton.new(hbox,{:active= => @alerts[name][0]}.freeze,'toggled'){|name|
      @alerts[name][0] = b0.active?
      # update daemon
      @pipe.puts "a #{@alerts.entry(name)}"; @pipe.flush; @pipe.puts "s #{Configuration::ALERTS_DATA_FILE}"; @pipe.flush
      label.text = @alerts.entry(name)
    }
    b0.is = name
    # here we don't throw away the streams as we may be watching and not in a pipe
    b1 = Gtk2AppLib::Widgets::Button.new(Configuration::TEST_BUTTON,hbox,'clicked'){|command| exec( command ) if fork.nil? }
    b1.is = @alerts[name].last # last item is the command
    b2 = Gtk2AppLib::Widgets::Button.new(Configuration::COPY_BUTTON,hbox,'clicked'){|name|
      @alert_editor.name = name
      @alert_editor.value = @alerts[name]
    }
    b2.is = name
    b3 = Gtk2AppLib::Widgets::Button.new(Configuration::DELETE_BUTTON,hbox,'clicked'){|name|
      @alerts.delete(name)
      @pipe.puts "d #{name}"; @pipe.flush; @pipe.puts "s #{Configuration::ALERTS_DATA_FILE}"; @pipe.flush
      hbox.destroy
    }
    b3.is = name

    label = Gtk2AppLib::Widgets::Label.new(@alerts.entry(name), hbox, Configuration::ALERT_LABEL_OPTIONS)

    if reorder then
      i = @alerts.keys.sort{|a,b| a.upcase<=>b.upcase}.index(name)
      self.reorder_child(hbox, i)
    end

    self.show_all
  end
end

end # End Of Module Gkt2AlertApp
