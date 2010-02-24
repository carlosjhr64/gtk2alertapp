module Gtk2AlertApp
  DIALOGS = Gtk2App::Dialogs.new()


class NameEntry < Gtk2App::Entry
  def initialize(pack)
    super('',pack){
      self.text = self.text.strip.gsub(/\W+/, '_')
      false
    }
  end
end

class AddButton
  ERROR = {:title=>'Error'}.freeze
  VERIFY = {:title=>'Verify'}.freeze
  OK = {:title=>'OK'}.freeze
  def initialize(pipe,alerts,pack)
    @entry_rows = nil # set later
    @add = Gtk2App::Button.new('Add', pack){|alert|
      name = alert.first.text.strip
      ok = true
      modifying = false
      if name.length == 0 then
        ok = false
        DIALOGS.question?('Need Alert Name',ERROR)
      elsif alerts[name] then
        ok = DIALOGS.question?("Overwrite #{name}?",VERIFY)
        modifying = ok
      end
      if ok then
        begin
          alerts.add( [name, alert[1].to_s, alert.last.text].join("\t") )
          pipe.puts "a #{alerts.entry(name)}"; pipe.flush; pipe.puts "s #{Configuration::ALERTS_DATA_FILE}"; pipe.flush
          @entry_rows.delete(name) if modifying
          @entry_rows.add(name, true) # add row to gui listing
          DIALOGS.question?("Added #{name}",OK)
        rescue
          puts_bang!
        end
      end
    }
    @add.value = nil
  end

  def value=(v)
    @add.value = v
  end

  def entry_rows=(hook)
    @entry_rows = hook
  end
end

class CronCommandRow < Gtk::HBox
  def initialize(pipe,alerts,cron,pack)
    super()
    @add = AddButton.new(pipe,alerts,self)
    @name = NameEntry.new(self)
    @add.value = [@name,cron,self]
    @command = Gtk2App::ComboBox.new(Configuration::PRESETS.map{|c| c[0]}, self)
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
    @option = Gtk2App::CheckButton.new(self)
    @option.modify_font(Configuration::FONT[:small])
    @label = Gtk2App::Label.new('', self)
    @message = Gtk2App::Entry.new('', self)
    # No Gtk2App support for FileChooserButton (yet? Needed?)
    @file_chooser = Gtk::FileChooserButton.new('Select a file', Gtk::FileChooser::ACTION_OPEN)
    self.pack_start(@file_chooser, false, false, Configuration::GUI[:padding])
    begin
      @file_chooser.signal_connect('file-set'){ @message.text = @file_chooser.filename }
    rescue Exception
      puts_bang!
    end

    @command.active = 0

    # race condition hack, run this after show_all later in code
    # TBD: architecture problem?
    Gtk.timeout_add(500){
      @label.hide
      @message.hide
      @file_chooser.hide
      @option.hide
      false
    }

    Gtk2App.pack(self,pack)
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

class CronTab < Gtk::HBox
  def initialize(text, pack, max=59, min=0)
    super()
    @check_button = Gtk2App::CheckButton.new(self,Configuration::CRON_TAB_OPTIONS)
    @label = Gtk2App::Label.new(text, self,Configuration::CRON_TAB_OPTIONS)
    @data1 = Gtk2App::SpinButton.new(self,{:min=>min,:max=>max,:step=>1}){ @data2.value = @data1.value }
    @data2 = Gtk2App::SpinButton.new(self,{:min=>min,:max=>max,:step=>1}){ @data1.value = @data2.value if @data1.value > @data2.value }
    Gtk2App.pack(self,pack)
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

class CronEntryRow < Gtk::VBox
  def initialize(cron, pack)
    super()
    now = Time.now

    cron.minute = CronTab.new('Minute',self)
    cron.minute.value = now.min

    cron.hour = CronTab.new('Hour', self, 23)
    cron.hour.value = now.hour

    cron.day = CronTab.new('Day', self, 31, 1)
    cron.day.value = now.day

    cron.month = CronTab.new('Month', self, 12, 1)
    cron.month.value = now.mon

    cron.wday = CronTab.new('Day Of Week', self, 7)
    cron.wday.value = now.wday

    Gtk2App.pack(self,pack)
  end
end

class Cron
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

class AlertEditor < Gtk::VBox
  def initialize(pipe, pack, alerts)
    super()

    # Cron Editor
    hbox = Gtk::HBox.new
    @cron = Cron.new
    @calendar = Gtk2App::Calendar.new(@cron, hbox)
    CronEntryRow.new(@cron, hbox)
    Gtk2App.pack(hbox,self)

    # Presets
    @ccr = CronCommandRow.new(pipe, alerts, @cron, self)

    # Command Editor
    hbox = Gtk::HBox.new
    @add = AddButton.new(pipe,alerts,hbox)
    @name = NameEntry.new(hbox)
    @command = Gtk2App::Entry.new('',hbox)
    @add.value = [@name,@cron,@command]

    # Packings
    Gtk2App.pack(hbox,self)
    Gtk2App.pack(self,pack)
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

class DigitalClock < Gtk2App::Label
  def initialize(strftime, pack)
    super(Time.now.strftime(strftime), pack)
    t = Gtk.timeout_add(1000){ self.text = Time.now.strftime(strftime) }
    self.signal_connect('destroy'){ Gtk.timeout_remove(t) }
  end
end

class EntryRows < Gtk::VBox
  def initialize(pipe, alert_editor, alerts, pack)
    super()
    @pipe = pipe			# pipe to alerts daemon
    @alert_editor = alert_editor	# hook to the alert editor
    @alerts = alerts			# the alerts hash/parser
    @rows = {}				# keeps a name/row map
    Gtk2App.pack(self,pack)
  end

  def delete(name)
    if row = @rows[name] then
      self.remove(row)
      row.destroy
      @rows.delete(name)
    end
  end

  def add(name, reorder=false)
    hbox = Gtk::HBox.new # create the new row to populate
    @rows[name] = hbox

    label = nil # set later
    # alerts[name] = [flag, minute, hour, day, month, wday, command]
    b0 = Gtk2App::CheckButton.new(hbox,{:active=>@alerts[name][0]}.freeze){|name|
      @alerts[name][0] = b0.active?
      # update daemon
      @pipe.puts "a #{@alerts.entry(name)}"; @pipe.flush; @pipe.puts "s #{Configuration::ALERTS_DATA_FILE}"; @pipe.flush
      label.text = @alerts.entry(name)
    }
    b0.value = name
    # here we don't throw away the streams as we may be watching and not in a pipe
    b1 = Gtk2App::Button.new('Test',hbox){|command| system( "#{command} &" )}
    b1.value = @alerts[name].last # last item is the command
    b2 = Gtk2App::Button.new('Copy',hbox){|name|
      @alert_editor.name = name
      @alert_editor.value = @alerts[name]
    }
    b2.value = name
    b3 = Gtk2App::Button.new('Delete',hbox){|name|
      @alerts.delete(name)
      @pipe.puts "d #{name}"; @pipe.flush; @pipe.puts "s #{Configuration::ALERTS_DATA_FILE}"; @pipe.flush
      hbox.destroy
    }
    b3.value = name

    label = Gtk2App::Label.new( @alerts.entry(name), hbox, Configuration::ALERT_LABEL_OPTIONS)
    Gtk2App.pack(hbox,self)

    if reorder then
      i = @alerts.keys.sort{|a,b| a.upcase<=>b.upcase}.index(name)
      self.reorder_child(hbox, i)
    end

    self.show_all
  end
end

end # End Of Module Gkt2AlertApp
