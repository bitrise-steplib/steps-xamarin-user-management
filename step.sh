#!/bin/bash

set -e

THIS_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -z "$build_slug" ]; then
	printf "\e[build_slug variable not set\e[0m\n"
	exit 1
fi

if [ -z "$xamarin_ios_license" ]; then
	printf "\e[31mxamarin_ios_license variable not set\e[0m\n"
	exit 1
fi

if [ -z "$xamarin_android_license" ]; then
	printf "\e[31mxamarin_android_license variable not set\e[0m\n"
	exit 1
fi

if [ -z "$xamarin_mac_license" ]; then
	export xamarin_mac_license="no"
fi

ruby "${THIS_SCRIPT_DIR}/step.rb"
