#!/bin/gawk -f
# this reads in an ics and converts it to calcurse format
#Mike Foster 3/1/2024

# filter with `sed '/^\t/d` to strip the notes.
# and `sed -n '/^\t/p'` for just notes.

# nominally all times are zulu time. Still no guarantee from the sender that they're *actually* using UTC.
# gawk is *required*, as we use mktime and strftime to deal with TZ data.

BEGIN { FS=":"; }

	function printEntry(sMo, sDay, sYear, summary, desc, hour, minute, dStart, dEnd) {
		# print out
		if(dEnd=="") { dEnd=sprintf("%s/%s/%s @ %02i:%02i", sMo, sDay, sYear, (sHr+hour), (sMin+minute)); };
		if(sHr=="") { printf("%s/%s/%s [1] %s\n", sMo, sDay, sYear, summary); 
			if(desc != "\t") {print desc;}; 
		} else {
		printf("%s -> %s |%s\n", dStart, dEnd, summary); 
			if(desc != "\t") {print desc;};
		};
	};

	function checkThings() {
		getline;
		if($0 ~ /^DTSTART/) { dStart=$2; sYear=substr(dStart,1,4); sMo=substr(dStart,5,2); sDay=substr(dStart,7,2); sHr=substr(dStart,10,2); sMin=substr(dStart,12,2); if($2 ~ /Z/) {zulu=true;} else {zulu=false;}; dStart=mktime(sYear " " sMo " " sDay " " sHr " " sMin " 00", zulu); dStart=strftime("%m/%d/%Y @ %H:%M",dStart); };
		if($0 ~ /^DTEND/) { dEnd=$2; eYear=substr(dEnd,1,4); eMo=substr(dEnd,5,2); eDay=substr(dEnd,7,2); eHr=substr(dEnd,10,2); eMin=substr(dEnd,12,2); dEnd=mktime(eYear " " eMo " " eDay " " eHr " " eMin " 00", zulu); dEnd=strftime("%m/%d/%Y @ %H:%M",dEnd); };
		if($0 ~ /^SUMMARY/) { summary=$0;sub(/^SUMMARY:/,"",summary); gsub("\\\\,", ",", summary);};
		if($0 ~ /^DESCRIPTION/) {desc=$0; getline; split($0,silly,""); while(silly[1]==" "){ sub(" ",""); desc=desc $0; getline; split($0,silly,"");}; gsub("\r","",desc); gsub("\\\\,", ",", desc); sub("DESCRIPTION:","\t",desc); };
		if($0 ~ /^DURATION/) { duration=$2; split(duration, a, /[PDTHMS]/); hour=a[4]; minute=a[5];};
		# strip out alarm clock
		if($0 ~ /^BEGIN:VALARM/) { while ($0 !~ /^END:VALARM/) {getline;}; };
	};

/^BEGIN:VEVENT/{ 
	dEnd=""; desc=""; sHr=""; duration=""; hour=1; minute=0; note="";
	while ($0 !~ /^END:VEVENT/) {
		checkThings();
	};
	# print out
	printEntry(sMo, sDay, sYear, summary, desc, hour, minute, dStart, dEnd); 
};

/^BEGIN:VTODO/{ 
	dEnd=""; desc=""; sHr=""; duration=""; hour=1; minute=0; note="";
	while ($0 !~ /^END:VTODO/) {
		checkThings();
	};
	# print out
	printEntry(sMo, sDay, sYear, summary, desc, hour, minute, dStart, dEnd); 
};

