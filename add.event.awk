#!/bin/nawk -f

# read in "mm/dd/yyyy hhmm headline"
# spit out calcurse apts format

/^[0-9]/ {
	group=$0; a=split(group,array," ");
	startDate=$1;
	#rounds variable tells us where to start splitting the array
	rounds=2;
	f=split(startDate,dates,"/");
	month=dates[1];
	day=dates[2];
	year=dates[3];
	  if(length(year) == 2) { year="20" year; };

	if($2 ~ /[0-9]/) {
	rounds=2;
	startTime=$2;
	hour=substr(startTime,1,2);
	s=length(startTime);
	if((s == 5) && ( startTime ~ /:/)) {};
	if((s == 4) && ( startTime !~ /:/)) {
	  minute=substr(startTime,3,2);
	  startTime=hour ":" minute;
	  };
	if(s == 2) { startTime=hour ":00"; };

	if($3 !~ /[0-9]/) {
	  rounds=3;
	  endTime=hour+1 ":00";
	} else {
	endTime=$3;
	s=length(endTime);
	if((s == 5) && ( endTime ~ /:/)) {};
	if((s == 4) && ( endTime !~ /:/)) {
	  ehr=substr(endTime,1,2);
	  minute=substr(endTime,3,2);
	  endTime=ehr ":" minute;
	  };
	if(s == 2) { endTime=endTime ":00"; };
	  rounds=4;
	};

	#everything is gathered, now to output!
	memo=array[rounds]; for (i=rounds+1;i<=a;i++) {memo=memo " " array[i];};
	printf("%s/%s/%s @ %s -> %s/%s/%s @ %s |%s\n", month, day, year, startTime, month, day, year, endTime, memo);
	} else {
	memo=array[rounds]; for (i=rounds+1;i<=a;i++) {memo=memo " " array[i];};
	printf("%s/%s/%s [1] %s\n", month, day, year, memo);
	};

};
