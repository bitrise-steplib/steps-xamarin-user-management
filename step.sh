#!/bin/bash

set -e

THIS_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -z "$bitrise_repository" ]; then
	printf "\e[31mbitrise_repository variable not set\e[0m\n"
	exit 1
fi

if [ -z "$xamarin_action" ]; then
	printf "\e[31mxamarin_action variable not set\e[0m\n"
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

ruby "${THIS_SCRIPT_DIR}/step.rb"
