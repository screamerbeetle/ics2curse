#!/bin/nawk -f
# this reads in an ics and converts it to calcurse format
#Mike Foster 2/29/2024

# filter with `sed '/^\t/d` to strip the notes.
# and `sed -n '/^\t/p'` for just notes.

# nominally all times are zulu time. Still no guarantee from the sender that they're *actually* using UTC.

BEGIN { FS=":"; TZ=""; localTZ=-7;}

	function printEntry(sMo, sDay, sYear, summary, desc, hour, minute, dStart, dEnd) {
		# print out
		if(dEnd=="") { dEnd=sprintf("%s/%s/%s @ %02i:%02i", sMo, sDay, sYear, (sHr+hour), (sMin+minute)); };
		if(sHr=="") { printf("%s/%s/%s [1] %s\n", sMo, sDay, sYear, summary); if(desc != "\t") {print desc;}; } else {
		printf("%s -> %s |%s\n", dStart, dEnd, summary); if(desc != "\t") {print desc;};};
	};

	function checkThings() {

		getline;
		if($0 ~ /^DTSTART/) { dStart=$2; sYear=substr(dStart,1,4); sMo=substr(dStart,5,2); sDay=substr(dStart,7,2); sHr=substr(dStart,10,2); sMin=substr(dStart,12,2); if($1 ~ /Los_Angeles/) { TZ=-8; } else { TZ=localTZ;}; if(dStart ~ /Z/) { sHr=sHr+TZ; }; };
		if($0 ~ /^DTEND/) { dEnd=$2; eYear=substr(dEnd,1,4); eMo=substr(dEnd,5,2); eDay=substr(dEnd,7,2); eHr=substr(dEnd,10,2); eMin=substr(dEnd,12,2); if($1 ~ /Los_Angeles/) { TZ=-8; } else { TZ=localTZ;}; if(dEnd ~ /Z/) { eHr=eHr+TZ; }; dEnd=sprintf("%s/%s/%s @ %02i:%02i", eMo, eDay, eYear, eHr, eMin);};
		if($0 ~ /^SUMMARY/) { summary=$0;sub(/^SUMMARY:/,"",summary); };
		if($0 ~ /^DESCRIPTION/) {desc=$0; getline; split($0,silly,""); while(silly[1]==" "){ sub(" ",""); desc=desc $0; getline; split($0,silly,"");}; gsub("\r","",desc); gsub("\\\\,", ",", desc); sub("DESCRIPTION:","\t",desc); };
		if($0 ~ /^BEGIN:VALARM/) { while ($0 !~ /^END:VALARM/) {getline;}; };
		# duration only shows up in vevents
		if($0 ~ /^DURATION/) { duration=$2; split(duration, a, /[PDTHMS]/); hour=a[4]; minute=a[5];};
	};

/^BEGIN:VEVENT/{ 
	dEnd=""; desc=""; sHr=""; duration=""; hour=1; minute=0;
	while ($0 !~ /^END:VEVENT/) {
		checkThings();
	};
	# print out
	printEntry(sMo, sDay, sYear, summary, desc, hour, minute, dStart, dEnd); 
};

/^BEGIN:VTODO/{ 
	dEnd=0; desc=""; sHr="";
	while ($0 !~ /^END:VTODO/) {
		checkThings();
	};
	# print out
	printEntry(sMo, sDay, sYear, summary, desc, hour, minute, dStart, dEnd); 

};

