# Old Historical Useless information, please do not read #

First:
Install "OpenSSH" using the Installer Application, and reboot your iPhone/iTouch (Hold down the power button and slide to power off and then turn it back on).

Connect your iPhone/iTouch to your home WiFi network (or a friend's WiFi network) and figure out what your IP address is, on the iPhone:
  1. Click on Settings -> Wi-Fi
  1. Select ">" on the WiFi network your iPhone is on
  1. remember the X.X.X.X "IP Address" on that page

Now get the file off of your iPhone by following these instructions:

Windows:
  1. download [PSCP](http://the.earth.li/~sgtatham/putty/latest/x86/pscp.exe) and save it in your c:\Windows directory
  1. open up a command line terminal Start->Run and type in "cmd" and hit OK
  1. Type in the following between the quotes (replace X.X.X.X with the IP address that you got above, and don't forget the period at the end)
`pscp root@X.X.X.X:/var/mobile/Library/MyTime™/record.plist .`
  1. enter "alpine" as the password
_restoring a backup is as simple as reversing the period and the root@blah blah stuff, but please be careful, you don't want to overwrite your calls._

OSX:
  1. open up a command line terminal "Applications/Utilities/Terminal"
  1. Type in the following between the quotes (replace X.X.X.X with the IP address that you got above, and don't forget the period at the end)
`scp root@X.X.X.X:/var/mobile/Library/MyTime™/record.plist .`
  1. enter "alpine" as the password
_restoring a backup is as simple as reversing the period and the root@blah blah stuff, but please be careful, you don't want to overwrite your calls._