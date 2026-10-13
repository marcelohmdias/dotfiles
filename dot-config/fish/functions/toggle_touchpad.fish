#!/usr/bin/env fish
set DEVICE "UNIW0001:00 093A:0255 Touchpad"

if udevadm info --export-db | string match -q "*$DEVICE*"
    sudo udevadm trigger --action=remove --property-match=NAME="$DEVICE"
    echo "Disable touchpad"
else
    sudo udevadm trigger --action=add --property-match=NAME="$DEVICE"
    echo "Enable touchpad"
end
