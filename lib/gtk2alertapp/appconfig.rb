module Gtk2AppLib
module Configuration
  # Set where the alert data file is.
  ALERTS_DATA_FILE = "#{USERDIR}/alerts.dat"

  # Widget Options, HNIL is just {}.freeze
  ALERT_NAME_ERROR = ['Need Alert Name',{:title=>'Error'}].freeze
  OVERWRITE_VERIFY = ['Overwrite?',{:title=>'Verify'}].freeze
  ALERT_ADDED = ['Added Alert',{:title=>'OK'}]
  ADD_BUTTON = ['Add',HNIL].freeze
  CRON_TAB_SPIN = HNIL
  COMBO_BOX = HNIL
  CRON_TAB_CHECK_BUTTON = HNIL
  CRON_TAB_LABEL = {:width_request= => 90}.freeze
  COMMAND_CHECK_BUTTON = {:modify_font=>FONT[:Small]}.freeze
  COMMAND_LABEL = HNIL
  COMMAND_ENTRY = {:width_request= => 300}.freeze
  CALENDAR = HNIL
  EDITOR_ENTRY = {:width_request= => 550}.freeze
  SELECT_A_FILE = [['Select a file', Gtk::FileChooser::ACTION_OPEN],HNIL].freeze
  TEST_BUTTON = ['Test',HNIL]
  COPY_BUTTON = ['Copy',HNIL]
  DELETE_BUTTON = ['Delete',HNIL]

  WEEKDAY = 'Day of week'
  MINUTE = 'Minute'
  HOUR = 'Hour'
  DAY = 'Day'
  MONTH = 'Month'

  ALERT_LABEL_OPTIONS = {:modify_font=>FONT[:Small]}.freeze

  FONT[:Small]  = Pango::FontDescription.new( 'Courier 8' )

  PRESETS = [
  # Menu's text		  command <--check entry/file>			check		entry		quoted?	file
  ['Festival Tells Time', "date +'It is %I:%M %p'  | festival --tts",	false,		false,		false,	false],
  ['Popup Alerts',	  'gtk2alert_popup',				'--tts',	'Message:',	true,	false],
  ['Open File',		  'gtk2alert_system',				false,		'File:',	false,	true],
	]

  # how about the system's open?
  FILE_APP_MAP = [
        # file pattern	open with	kill app?
	[/\.wav$/i,	'aplay',	true],
	[/\.mp3$/i,	'mpg123',	true],
	[/\.mid$/i,	'timidity',	true],
	[/^http:\/\//,	APPLICATION[:browser], 	false],
	]

  KILL_APP_DIALOG = ["Kill File's Application?",{:Dialog_Buttons=>[["Yes",1],["No",0]]}].freeze

# open/close are so fast, dock seems wasteful.
# MENU[:dock] = '_Dock'	# Dock only hides GUI
  MENU[:close] = '_Close' #  Close destroys GUI, but keeps daemon running. Goes to tray.
end
end
