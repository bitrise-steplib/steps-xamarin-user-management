#!/bin/bash

set -e

THIS_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -z "$build_slug" ]; then
	printf "\e[build_slug variable not set\e[0m\n"
	exit 1
fi

ruby "${THIS_SCRIPT_DIR}/step.rb"
