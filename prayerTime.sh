#!/bin/bash

msgId="991148"
scriptname=$( basename "$0" )
is_running=$( pgrep -cf "$scriptname" )
if (( $is_running > 1 )) && [[ -z "$1" ]] ; then
    >&2 echo $scriptname is running.
    exit 0
fi

dir="prayerTime/salat"
declare -A v
#1,2..5 are files with arabic prayer names
v["Fajr"]=1
v["Dhuhr"]=2
v["Asr"]=3
v["Maghrib"]=4
v["Isha"]=5

function CURL (){
    userAgent="Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:48.0) "
    userAgent+="Gecko/20100101 Firefox/48.0"
    curl -s -A "$userAgent" "$@"
}

CURL 'https://www.islamicfinder.org/' \
|sed -n -e '/Upcoming Prayer/{N;N;N;N;N;N;N;s/<[^>]*>//g;s/\s\s*/ /g;p}' \
>| "/tmp/nextPrayerTime"

if ! [[ -z "$1" ]] ; then exit ; fi

while true ; do
    sleep 1
    nextPrayerName="$(cat "/tmp/nextPrayerTime" | cut -d' ' -f4 )"
    nextPrayerTime="$(cat "/tmp/nextPrayerTime" | cut -d' ' -f5 )"
    h=$(echo $nextPrayerTime|cut -d: -f1 )
    m=$(echo $nextPrayerTime|cut -d: -f2 )
    s=$(echo $nextPrayerTime|cut -d: -f3 )
    if [[ -z "$h" ]] || [[ -z "$m" ]] || [[ -z "$h" ]] ; then
        code=$(ping -c 1 8.8.8.8 2>&1 |grep unreachable >/dev/null; echo $? )
        (( code == 0 )) && {
            >&2 echo "PrayerTime: waiting for network..."
            sleep 30
            continue
        }
        >&2 echo "PrayerTime: getting data..."
        CURL 'https://www.islamicfinder.org/' \
        |sed -n -e '/Upcoming Prayer/{N;N;N;N;N;N;N;s/<[^>]*>//g;s/\s\s*/ /g;p}' \
        >| "/tmp/nextPrayerTime"
        continue
    fi
    if (( $s > 0 )) ;  then
            s=$((s-1))
        elif (( $m > 0)) ; then
            m=$((m-1))
            s=59
        elif (( $h > 0)) ; then
            h=$((h-1))
            m=59
            s=59
        else
            pn=${v[$nextPrayerName]}
            dunstify -u critical -r "$msgId"  "$(cat "$dir/t") $(cat "$dir/$pn")"
            CURL 'https://www.islamicfinder.org/' \
            |sed -n -e '/Upcoming Prayer/{N;N;N;N;N;N;N;s/<[^>]*>//g;s/\s\s*/ /g;p}' \
            >| "/tmp/nextPrayerTime"
            continue
    fi
    echo " Upcoming Prayer $nextPrayerName $h:$m:$s" >| "/tmp/nextPrayerTime"
    #change prayer name to arabic by "cat"ing the corresponding file
    pn=${v[$nextPrayerName]}
    Atext="$(cat "$dir/s") $(cat "$dir/$pn") $(cat "$dir/a")"
    Atext+="  $(echo "$h:$m:$s"|rev)"
    echo "$Atext " >| "/tmp/nextPrayerTimeA"
done
