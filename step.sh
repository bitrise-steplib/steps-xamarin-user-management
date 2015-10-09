#!/bin/bash

mdtool="${xamarin_studio}/Contents/MacOS/mdtool"

if [ ! -e "${mdtool}" ]; then
	echo "mdtool not found at path ${mdtool}"
	exit 1
fi

case "$xamarin_action" in
	login)
		if [ -z "${xamarin_username// }" ]; then 
			echo "Xamarin username not set or empty"
			exit 1
		fi

		if [ -z "${xamarin_password// }" ]; then 
			echo "Xamarin password not set or empty"
			exit 1
		fi

		"${mdtool}" account login -u "${xamarin_username}" -p "${xamarin_password}"
		if [ $? == 0 ]; then
			"${mdtool}" account info
		fi
		;;
	logout)
		"${mdtool}" account logout
		;;
	*)
		echo "unknown command: ${xamarin_action}"
		exit 1
esac