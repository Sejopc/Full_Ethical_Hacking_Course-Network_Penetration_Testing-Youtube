#!/bin/bash

if [ $# -lt 2 ]; 
then
	echo "Breach Parse v2: A Breached Domain Parsing Tool by Heath Adams"
	echo " "
	echo "Usage: ./breach-parse.sh <domain to search> <file to output> [breach data location]"
	echo "Example: ./breach-parse.sh @gmail.com gmail.txt \"~/Downloads/BreachCompilation/data\""
	echo "You only need to specify [breach data location] if it's not in the expected location (/opt/breach-parse/BreachCompilation/data)"
	echo " "
	echo "For multiple domain: /breach-parse.sh \"<domain to searh>|<domain to search>\" <file to output>"
	echo "Example ./breach-parse.sh \"@gmail.com|@yahoo.com\" multiple.txt"
	exit 1
else
	if [ $# -ge 4 ]; then
		echo "You supplied more than 3 arguments, make sure you double quote your strings:"
		echo "Example: ./breach-data.sh @gmail.com gmail.txt \"~/Downloads/Temp Files/BreachCompilation\""
		exit 1
	fi

	# assume default location
	breachDataLocation="/opt/breach-parse/BreachCompilation/data"
	# check if BreachCompilation was specified to be somewhere else
	if [ $# -eq 3 ]; then
		if [ -d "$3" ]; then
			breachDataLocation="$3"
		else
			echo "Could not find a directory at ${3}"
			echo "Pass the BreachCompilation/data directory as the third argument"
			echo "Example: ./breach-parse.sh @gmail.com gmail.txt \"~/Downloads/BreachCompilation/data\""
			exit 1
		fi
	else
		if [ ! -d "${breachDataLocation}" ]; then
			echo "Could not find a directory at ${breachDataLocation}"
			echo "Put the breached password list there or specify the location of the BreachCompilation/data as the third argument"
			echo "Example: ./breach-parse.sh @gmail.com gmail.txt \"~/Downloads/BreachCompilation/data\""
			exit 1
		fi
	fi

	# Set output files
	fullfile=$2
	fbname=$(basename "$fullfile" | cut -d. -f1)
	master=$fbname-master.txt
	users=$fbname-users.txt
	passwords=$fbname-passwords.txt

	touch $master # Create the file

	# count lines for progressBar
	# -not -path '*/\.*' ignore hidden files/directories that have been created by the OS
	total_Files=$(find "$breachDataLocation" -type f -not -path '*/\.*' | wc -l)
	file_Count=0

	function progressBar() {
		
		let _progress=$((($file_Count * 100 / $total_Files * 100) / 100))
		let _done=$((($_progress * 4) / 10))
		let _left=$((40 - $_done))

		_fill=$(printf "%${_done}s")
		_empty=$(printf "%${_left}s")

		printf "\rProgress : [${_fill// /\#}${_empty// /\-}] ${_progress}%%"
	}

	# grep for passwords
	find "$breachDataLocation" -type f -not -path '*/\.*' -print0 | while read -d $'\0' file; do
		grep -a -E "$1" "$file" >> $master
		((++file_Count))
		progressBar ${number} ${total_Files}

	done
fi

sleep 3

echo #newline
echo "Extracting usernames..."
awk -F':' '{print $1}' $master > $users
sleep 1

echo "Extracting passwords..."
awk -F':' '{print $2}' $master > $passwords
echo
exit 0
