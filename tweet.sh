#!/bin/bash
#Twitter status update bot by http://360percents.com
#Author: Luka Pusic <pusic93@gmail.com>

#REQUIRED PARAMS
username="your@email.com"
password="yourpassw0rd"
tweet="$*" #must be less than 140 chars

#EXTRA OPTIONS
uagent="Mozilla/5.0" #user agent (fake a browser)
sleeptime=0 #add pause between requests

# Usage information
optstring=h

usage ()
{
   printf "%s\n" " Usage: ./tweet.sh [-h help] " \
                 " Usage: ./tweet.sh \"status update\"" \
                 " -h ... usage information. You are reading it." \
                 " Type ./tweet.sh follwed by your status update. Your tweet must not be longer than 140 chars!"
}

while getopts $optstring opt
do
   case $opt in
      h) usage; exit 0 ;;
      *) usage ; exit 1 ;;
   esac
done

shift "$(( $OPTIND -1 ))"

if (( ${#tweet} > 140 ))
then
   printf "%s\n" " [FAIL] Tweet must not be longer than 140 chars!"
   usage && exit 1
fi

if [[ -z $tweet ]]
then
   printf "%s\n" " [FAIL] Nothing to tweet. Enter your text as argument."
   usage && exit 1
fi

touch "cookie.txt" #create a temp. cookie file

#INITIAL PAGE
echo "[+] Fetching twitter.com..." && sleep $sleeptime
initpage=`curl -s -b "cookie.txt" -c "cookie.txt" -L --sslv3 -A "$uagent" "https://mobile.twitter.com/session/new"`
token=`echo "$initpage" | grep "authenticity_token" | sed -e 's/.*value="//' | sed -e 's/" \/>.*//'`

#LOGIN
echo "[+] Submitting the login form..." && sleep $sleeptime
loginpage=`curl -s -b "cookie.txt" -c "cookie.txt" -L --sslv3 -A "$uagent" -d "authenticity_token=$token&username=$username&password=$password" "https://mobile.twitter.com/session"`

#HOME PAGE
echo "[+] Getting your twitter home page..." && sleep $sleeptime
homepage=`curl -s -b "cookie.txt" -c "cookie.txt" -L -A "$uagent" "http://mobile.twitter.com/"`

#TWEET
echo "[+] Posting a new tweet: ${tweet}..." && sleep $sleeptime
tweettoken=`echo "$homepage" | grep "authenticity_token" | sed -e 's/.*value="//' | sed -e 's/" \/>.*//' | tail -n 1`
update=`curl -s -b "cookie.txt" -c "cookie.txt" -L --sslv3 -A "$uagent" -d "authenticity_token=$tweettoken&tweet[text]=$tweet&tweet[display_coordinates]=false" "https://mobile.twitter.com/"`

#LOGOUT
echo "[+] Logging out..."
logout=`curl -s -b "cookie.txt" -c "cookie.txt" -L -A "$uagent" "http://mobile.twitter.com/session/destroy"`

rm "cookie.txt"
