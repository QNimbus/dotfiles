#!/usr/bin/env bash
#===================================================================================
#
# FILE: dotfiles.sh
#
# USAGE: dotfiles.sh
#
# DESCRIPTION: ....
#
# OPTIONS: see function ’usage’ below
# REQUIREMENTS:
# BUGS:
# NOTES:
# AUTHOR: B. van Wetten, bas@b2.io
# COMPANY: BeSquared
# VERSION: 0.1
# CREATED: 27.10.2013
#===================================================================================

#
# Disable echo of keypress during script execution
#
_STTY=$(stty -g) && stty -echo

#
# Global variables
#
_PROGNAME=$(basename $0)
_REPO="https://github.com/QNimbus/dotfiles.git"
_HOME_DIR="${HOME}"
_TARGET_DIR="${HOME}/.dotfiles"

function restore_tty() { stty "$_STTY"; }

#
# Tweak file globbing.
#
shopt -s dotglob
shopt -s nullglob

#
# Let this script do it's own error handling
#
#exec 2> /dev/null

echo "DotFiles - B. van Wetten (c) 2013 BeSquared - http://b2.io"

#
# check if the command line parameter 'h' or '--help' was entered
#
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
	cat <<HELP
Usage: $_PROGNAME

See the README for documentation.
https://github.com/QNimbus/dotfiles.git

Copyright (c) 2013 B. van Wetten
HELP

	exit;
fi

#
# Handle normal error, exit, abort and kill scenarios
#
trap 'restore_tty && abort' INT TERM
trap 'restore_tty && finish' EXIT
trap 'restore_tty && error ${LINENO}' ERR

#
# fancy logging functions
#
function e_header()	{ echo -e "\n\033[1m$@\033[0m"; 	}
function e_success()	{ echo -e " \033[1;32m✔\033[0m  $@"; 	}
function e_successy()	{ echo -e " \033[1;33m✔\033[0m  $@"; 	}
function e_error()	{ echo -e " \033[1;31m✖\033[0m  $@"; 	}
function e_notice()	{ echo -e " \033[1;33m✖\033[0m  $@"; 	}
function e_question()	{ echo -e " \033[1;33m?\033[0m  $@"; 	}
function e_skip()	{ echo -e " \033[1;33m!\033[0m  $@"; 	}
function e_message()	{ echo -e " \033[1m.\033[0m  $@";			}
function e_arrowy()	{ echo -e " \033[1;33m➜\033[0m  $@"; 	}
function e_arrowb()	{ echo -e " \033[1;34m➜\033[0m  $@";	}
function e_arroww()	{ echo -e " \033[1;37m➜\033[0m  $@";	}

#
# This function displays an error message 
#
function error_exit
{
	e_error "${_PROGNAME}: ${1:-"Unknown Error"}" 1>&2
	exit 1
}

function error()
{
	local parent_lineno="$1"
	local message="$2"
	local code="${3:-1}"
	if [[ -n "$message" ]] ; then
		e_error "Error on or near line ${parent_lineno}: ${message}; exiting with status ${code}"
	else
		e_error "Error on or near line ${parent_lineno}; exiting with status ${code}"
	fi
	exit "${code}"
}

#
# This function gets called when the script exits
#
function finish()
{
	e_header "Exiting..."
}

#
# This function gets called when the script exits
#
function abort()
{
	echo -e
	e_error "Aborting... (cleaning up)"
	reset
	exit 1
}

#
# Offer the user a chance to skip something.
#
function skip()
{
	e_skip "$1: To skip, press X within 10 seconds..."
	read -t 10 -n 1 -s
	if [[ "$REPLY" =~ ^[Xx]$ ]]; then
		e_message "Skipping ($1)"
		return 0
	else
		e_message "Continuing...($1)"
		return 1
	fi
	return 0
}

##############################################################
##############################################################
############## Core functions ################################
##############################################################
##############################################################

#
# Initialize.
#
function init_test()
{
	if  [[ ! -s $1 ||! -r $1 ]]; then
		echo "Cannot read from $1 or file is empty"
	fi
}

function init_header()
{
	e_header "Initial configuration & checks"
}

function init_do()
{
	source "$2"
	ret_value=$?
	if [[ $ret_value -ne 0 ]]; then
		e_error "Encountered problem with $1"
	fi

}

#
# Copy files
#
function copy_test()
{
	if  [[ ! -s $1 ||! -r $1 ]]; then
		echo "Cannot read from $1 or file is empty"
	fi
}

function copy_header()
{
	e_header "Copying files to homedirectory ($HOME)"
}

function copy_do()
{
	cp "$2" "$HOME/$1"
	ret_value=$?
	if [[ $ret_value -ne 0 ]]; then
		e_error "Encountered problem while copying $2 to $HOME/$1"
	else
		e_success "Copied $2 to $HOME/$1"
	fi
}

#
# Link files
#
function link_test()
{
	if  [[ ! -f $1 ]]; then
		echo "Cannot create symbolic link to $1"
	fi
}

function link_header()
{
	e_header "Linking files in homedirectory ($HOME)"
}

function link_do()
{
	ln -fs "$2" "$HOME/$1"
	ret_value=$?
	if [[ $ret_value -ne 0 ]]; then
		e_error "Encountered problem while creating symbolic link $2 => $HOME/$1"
	else
		e_success "Created symbolic linked $2 => $HOME/$1"
	fi

}

function stage
{
	local base dest skip
	local files=($HOME/.dotfiles/$1/*)

	# Directory does not exist? Abort...
	if [[ ! -d "$HOME/.dotfiles/$1" ]]; then e_error "Directory $HOME/.dotfiles/$1 does not exist"; return; fi

	# No files found? Abort...
	if (( ${#files[@]} == 0 )); then e_error "No files found in '$1' subdirectory"; return; fi

	# Run _header function only if declared.
	[[ $(declare -f "$1_header") ]] && "$1_header"

	# Iterate over files.
	for file in "${files[@]}"; do
		base="$(basename $file)"
		dest="$HOME/$base"

		# Run _test function only if declared.
		if [[ $(declare -f "$1_test") ]]; then
			# If _test function returns anything (e.g. string), skip file and print that message.
			skip="$("$1_test" "$file" "$dest")"
			if [[ "$skip" ]]; then
				e_error "Skipping $base, $skip."
				continue
			fi
		fi

		# Execute the function
		"$1_do" "$base" "$file"
	done
}

##############################################################
##############################################################
############## Main program ##################################
##############################################################
##############################################################

#
# Update existing sudo time stamp if set, otherwise do nothing.
#
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

#
# If Git is not installed, install it
#
if [[ ! "$(type -P git)" ]]; then
        sudo apt-get -qq install git-core && e_success "$SUBJECT: Success" || (e_error "$SUBJECT: Failed"; exit 1)
fi

#
# If Git isn't installed by now, something exploded. We gots to quit!
#
if [[ "$(type -P git)" ]]; then
        e_success "Git is installed"
else
        e_error "Git should be installed. It isn't. Aborting."
        exit 1
fi

#
# Clone dotfiles repo or pull latest changes if the directory already exists
#
if [[ ! -d "$_TARGET_DIR" ]]; then
	new_dotfiles_install=1
	e_message "Downloading dotfiles from git repo"
	if ! git clone --quiet --recursive "$_REPO" "$_TARGET_DIR"; then
		e_error "There was a problem cloning the git repository $_REPO"
		exit 1
	else
		e_success "Successfully cloned the git repository $_REPO"
	fi
	cd "$_TARGET_DIR"
else
	# Make sure we have the latest files.
	e_message "Updating dotfiles"
	#cd "$_TARGET_DIR"
	#(git pull --quiet && git submodule update --init --recursive --quiet) && e_success "Successfully pulled latest changes from the git repository $_REPO" || (e_error "There was a problem pulling from the git repository $_REPO"; exit 1)
fi

stage init
stage copy
stage link
