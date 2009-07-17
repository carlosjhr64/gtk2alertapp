module Configuration
  MENU[:close] = '_Close'

  SPIN_BUTTON_WIDTH = 40
  INITKEY = 'aaaa'

  SNOOZE = 15*60 # Fifteen minute snooze default
  SNOOZE_MESSAGE = 'Remind me again later.'
  CANCEL_MESSAGE = 'Got it!'

  PRESETS = [
  # Menu's text		  command <--check entry/file>			check		entry		quoted?	file
  ['Festival Tells Time', "date +'It is %I:%M %p'  | festival --tts",	false,		false,		false,	false],
  ['Popup Alerts',	  'gtk2alert_popup',				'--tts',	'Message:',	true,	false],
  ['Open File',		  'gtk2alert_system',				false,		'File:',	false,	true],
  ['Run',		  '',						false,		'Command:',	false,	false],
	]

  FILE_APP_MAP = [
        # file pattern	open with	kill app?
	[/\.wav$/i,	'aplay',	true],
	[/\.mp3$/i,	'mpg123',	true],
	[/^http:\/\//,	APP[:browser], 	false],
	]
end
