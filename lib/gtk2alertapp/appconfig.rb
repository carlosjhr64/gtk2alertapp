# Pango defined in gtk2
# Gtk defined
module Gtk2AppLib # Gtk2AppLib defined
module Configuration
  # FONT defined in gtk2applib/configuration
  FONT[:SMALL]  = Pango::FontDescription.new( 'Courier 8' )
  # MENU defined in gtk2applib/configuration
  # open/close are so fast, dock seems wasteful.
  # MENU[:dock] = '_Dock'	# Dock only hides GUI
  MENU[:close] = '_Close' #  Close destroys GUI, but keeps daemon running. Goes to tray.
  MENU[:help] = '_Help'
end
end

module Gtk2AlertApp
module Configuration
  # Set where the alert data file is.
  ALERTS_DATA_FILE = "#{Gtk2AppLib::USERDIR}/alerts.dat"

  hnil = Gtk2AppLib::HNIL
  # Widget Options, HNIL is just {}.freeze
  ALERT_NAME_ERROR = ['Need Alert Name',{:TITLE=>'Error',:SCROLLED_WINDOW=>false}].freeze
  OVERWRITE_VERIFY = ['Overwrite?',{:TITLE=>'Verify'}].freeze
  ALERT_ADDED = ['Added Alert',{:TITLE=>'OK',:SCROLLED_WINDOW=>false}]
  ADD_BUTTON = ['Add',hnil].freeze
  CRON_TAB_SPIN = hnil
  COMBO_BOX = hnil
  CRON_TAB_CHECK_BUTTON = hnil
  CRON_TAB_LABEL = {:width_request= => 90}.freeze
  COMMAND_CHECK_BUTTON = {:modify_font=>Gtk2AppLib::Configuration::FONT[:SMALL]}.freeze
  COMMAND_LABEL = hnil
  COMMAND_ENTRY = {:width_request= => 300}.freeze
  CALENDAR = hnil
  EDITOR_ENTRY = {:width_request= => 550}.freeze
  SELECT_A_FILE = [['Select a file', Gtk::FileChooser::ACTION_OPEN],hnil].freeze
  TEST_BUTTON = ['Test',hnil]
  COPY_BUTTON = ['Copy',hnil]
  DELETE_BUTTON = ['Delete',hnil]

  WEEKDAY = 'Day of week'
  MINUTE = 'Minute'
  HOUR = 'Hour'
  DAY = 'Day'
  MONTH = 'Month'

  ALERT_LABEL_OPTIONS = {:modify_font=>Gtk2AppLib::Configuration::FONT[:SMALL]}.freeze

  text2speech = Gtk2AppLib.which([
	[ 'festival',	' --tts '	],
	[ 'espeak',	' '             ],
  ])

  PRESETS = [
  # Menu's text		  command <--check entry/file>			check		entry		quoted?	file
  ["#{File.basename(text2speech.strip.split(/\s+/).first).capitalize} Tells Time", "date +'It is %I:%M %p'  | #{text2speech} 2> /dev/null",	false,		false,		false,	false],
  ['Popup Alerts',	  'gtk2alert_popup',				'--tts',	'Message:',	true,	false],
  ['Open File',		  'gtk2alert_system',				false,		'File:',	false,	true],
	]

  DEFAULT_APPLICATION = 'gnome-open'
  FILE_APP_MAP = [
        # file pattern	open with	kill app?
	[/\.wav$/i,	'aplay',	true],
	[/\.mp3$/i,	'xmms',		true],
	[/\.mid$/i,	'timidity',	true],
	[/^http:\/\//,	Gtk2AppLib::Configuration::APPLICATION[:BROWSER], 	false],
	]

  KILL_APP_DIALOG = ["Kill File's Application?",{:DIALOG_BUTTONS=>[["Yes",1],["No",0]]}].freeze
end
end
