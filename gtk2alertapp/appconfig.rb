module Configuration
  # Set where the alert data file is.
  ALERTS_DATA_FILE = "#{UserSpace::DIRECTORY}/alerts.dat"

  WIDGET_OPTIONS[:nameentry_width]	= 100	# NAME ENTRY WIDTH
  WIDGET_OPTIONS[:entry_width]		= 400	# COMMAND WIDTH
  WIDGET_OPTIONS[:wrap] = false
  WIDGET_OPTIONS.freeze

  CRON_TAB_OPTIONS = {:label_width=>90}.freeze
  ALERT_LABEL_OPTIONS = {:font=>Configuration::FONT[:small]}.freeze

  FONT[:small]  = Pango::FontDescription.new( 'Courier 8' )

  PRESETS = [
  # Menu's text		  command <--check entry/file>			check		entry		quoted?	file
  ['Festival Tells Time', "date +'It is %I:%M %p'  | festival --tts",	false,		false,		false,	false],
  ['Popup Alerts',	  'gtk2alert_popup',				'--tts',	'Message:',	true,	false],
  ['Open File',		  'gtk2alert_system',				false,		'File:',	false,	true],
	]

  FILE_APP_MAP = [
        # file pattern	open with	kill app?
	[/\.wav$/i,	'aplay',	true],
	[/\.mp3$/i,	'mpg123',	true],
	[/^http:\/\//,	APP[:browser], 	false],
	]

# open/close are so fast, dock seems wasteful.
# MENU[:dock] = '_Dock'	# Dock only hides GUI
  MENU[:close] = '_Close' #  Close destroys GUI, but keeps daemon running. Goes to tray.
end
