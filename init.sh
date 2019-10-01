#! /bin/bash

# This script is supposed to:
# - check the date and compare to the last usage of the button
# - if more than 48h as passed since last use, send a POST request using curl to Zappier URL
# - this request contains an Authorization header and the current date
# - it waits for a 200 response or retries to send request
# - it then needs to shutdown the device

CURRENT_DATE=`date +"%F-%H:%M"`
NOT_BEFORE=`date -v+2d +"%F-%H:%M"`

echo "Current date and time is : ${CURRENT_DATE}"
echo "Don't order before: ${NOT_BEFORE}"

[[ -f next-orders.txt ]] && echo "File found" || touch next-orders.txt

if [[ `tail -1 next-orders.txt` < $CURRENT_DATE ]];then
	echo "Can order"
else
	echo "Don't!!"
fi

