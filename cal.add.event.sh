#!/bin/dash

# This is to add an event to calcurse. 
# Add the note in program, as the sha1 calc isn't working.
# if you want to add a bunch of events, make a text file, and use add.event.awk to parse it, dumping stdout into the apts file

appointments="$HOME/.local/share/calcurse/apts"
#appointments=/tmp/appts

[ "$1" ] || { printf "Usage: `basename $0` \"mm/dd/yyyy\" \"HH:MM\" \"headline/summary\" \n"; exit 0; }

echo "$@" | add.event.awk |tee -a $appointments
