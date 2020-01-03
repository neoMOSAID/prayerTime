# prayerTime

this is a script that "scraps" reads the html code  containing time remaining untill the next prayer from https://www.islamicfinder.org/.

then it it enters an infinte while loop decrementing the time "hh:mm:ss" untill it hits zero (ie the prayer time)
then it gets the new data from the website again

each second the new time "hh:mm:ss" and "prayer name" is saved in /tmp/nextPayerTime
another functionality is to change the english prayer name provided by the website into an arabic one
then fed to conky script via conky-prayer.sh. this script reads the content of  /tmp/nextPayerTimeA 
and echo it using python arabic-reshaper for a proper rendering of arabic in conky 

one should install arabic-reshaper if not exists in their system via:

$ sudo pip install arabic-reshaper

![Alt text](https://github.com/neoMOSAID/prayerTime/blob/master/preview.png?raw=true "preview")
