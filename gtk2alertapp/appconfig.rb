module Configuration
  # Set where the alert data file is.
  ALERTS_DATA_FILE = "#{UserSpace::DIRECTORY}/alerts.dat"

  NAME_ENTRY_WIDTH = 100
  CRON_TAB_WIDTH = 90 # Labels next to the spin buttons.
  COMMAND_WIDTH = 400
  ENTRY_WIDTH = 500

  SNOOZE = 15*60 # Fifteen minute snooze default
  SNOOZE_MESSAGE = 'Remind me again later.'
  CANCEL_MESSAGE = 'Got it!'

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
