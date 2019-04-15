#!/bin/bash

# At each click, the script change the current desktop
# state (to hide or no icons on the desktop).
# 
# This script display a checkmark on Hello IT menu 
# when the desktop is hidden. The script don't provide
# any built-in title. So use the Hello IT title setting
# to set something coherent for your main language.
# Something like "Presenter Mode" or "Hide Desktop".

. "$HELLO_IT_SCRIPT_SH_LIBRARY/com.github.ygini.hello-it.scriptlib.sh"

function doesDesktopIsCurrentlyHidden {
	returnCode=$(defaults read com.apple.finder CreateDesktop | grep -i false | wc -l | bc)
	return $returnCode
}

function toggleDND {

user=$( /bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }' )


if [ "$1" == "true" ]; then
	cat << EOF > "/Users/$user/.dnd.sh"
	#!/bin/sh
	defaults -currentHost write ~/Library/Preferences/ByHost/com.apple.notificationcenterui doNotDisturb -bool true
	defaults -currentHost write ~/Library/Preferences/ByHost/com.apple.notificationcenterui doNotDisturbDate -date "$(date)"
	defaults -currentHost read ~/Library/Preferences/ByHost/com.apple.notificationcenterui
	killall NotificationCenter
EOF
else
	cat << EOF > "/Users/$user/.dnd.sh"
	#!/bin/sh
	defaults -currentHost write ~/Library/Preferences/ByHost/com.apple.notificationcenterui doNotDisturb -bool false
	defaults -currentHost write ~/Library/Preferences/ByHost/com.apple.notificationcenterui doNotDisturbDate -date "$(date)"
	defaults -currentHost read ~/Library/Preferences/ByHost/com.apple.notificationcenterui
	killall NotificationCenter
EOF
fi
chmod +x "/Users/$user/.dnd.sh"

"/Users/$user/.dnd.sh"

rm -f "/Users/$user/.dnd.sh"

}

function updateTitleAccordingToCurrentState {
    doesDesktopIsCurrentlyHidden
    isHidden=$?
	
	if [ $isHidden == 0 ]
	then
		echo "hitp-checked: NO"
	else
		echo "hitp-checked: YES"
	fi
}

function onClickAction {
    doesDesktopIsCurrentlyHidden
    isHidden=$?
    
    if [ $isHidden == 1 ]
	then
		defaults write com.apple.finder CreateDesktop true
		toggleDND "false"
		updateState "${STATE[4]}"
	else
		defaults write com.apple.finder CreateDesktop false
		toggleDND "true"
		updateState "${STATE[3]}"
	fi
	
	killall Finder
    
    updateTitleAccordingToCurrentState
}

function fromCronAction {
    updateTitleAccordingToCurrentState
}

function setTitleAction {
    updateTitleAccordingToCurrentState
}

main $@

exit 0
