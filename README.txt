Ruby-Gnome Alerts allows one to set up alarms like an alarm clock.

Does not use cron, but can be used for cron functionality.
Play sound files at set times.
Have Festival announce time or nag you about chores.

With "Festival Tells Time",
one can have the computer announce the time at regular times.
If festival is not available, but another TTS program is,
one can modify
	~/.gtk2alertapp-1/appconfig-1.2.rb
to use it instead.

With "Popup Alert",
one can have the computer announce a message and
leave a popup with the message at regular times.
This feature is useful for regular chores reminders,
such as trash day, or billings day, etc...
One can quickly set up a reminder for an re-accuring event,
up to yearly events such as birthdays...
One time events? Just delete the entry after it's run.

With "Open File",
one can have the computer play a wav or mp3 file
at regular times, such as a grand-father clock gong wav file...
or a music mp3 file.
If given a url like 'http://....', then a web-browser will open that page.
One can also add to the playable files and runnable applications by
editing FILE_APP_MAP in the configuration file:
	~/.gtk2alertapp-1/appconfig-1.2.rb

Lastly, one can run an arbitrary command.

The alerts will be active only as long as the application is running.
The system's cron is not used.
