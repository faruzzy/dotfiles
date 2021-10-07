# warning
# there is a none bug with this script that will cause you to lose access to finder and the background
# When that happens the fix is to delete the desktoppicture database located at: ~/Library/Application Support/Dock/desktoppicture.db
read -e IMAGE;
sqlite3 ~/Library/Application\ Support/Dock/desktoppicture.db "update data set value = '$IMAGE'" && killall Dock