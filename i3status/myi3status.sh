#!/usr/bin/zsh

# Date: Apr 12 2017 Ashish Gupta Initial implementation.
#                   An extension to the i3status command.

i3status | while :
do
    read LINE
    #BYTES=$(ifconfig enp0s3 | awk -F"[ :()]+" '/RX bytes/{print "RX:", $4, $5, "TX:", $9, $10}')
    USER_RAM=$(/bin/ps -u $(whoami) -o pid,rss,command | awk '{sum+=$2} END {print sum / 1024 " MB"}')
    ROOT_RAM=$(/bin/ps -u root -o pid,rss,command | awk '{sum+=$2} END {print sum / 1024 " MB"}')
    TXBYTES=$(ifconfig enp0s3 | awk -F"[ :()]+" '/RX/{ printf "%d", $9 }' | numfmt --grouping)
    RXBYTES=$(ifconfig enp0s3 | awk -F"[ :()]+" '/RX/{ printf "%d", $4 }' | numfmt --grouping)
    echo "RX: $RXBYTES TX: $TXBYTES | ROOT RAM: $ROOT_RAM | USER RAM: $USER_RAM | $LINE" || exit 1
done
