#! /bin/bash

# This script is supposed to:
# - check the date and compare to the last usage of the button
# - if more than 48h as passed since last use, send a POST request using curl to Zappier URL
# - this request contains an Authorization header and the current date
# - it waits for a 200 response or retries to send request
# - it then needs to shutdown the device
source ./.env

CURRENT_DATE=`date +"%F-%H:%M"`
NOT_BEFORE=`date -v+2d +"%F-%H:%M"`

echo "Current date and time is : ${CURRENT_DATE}"
echo "Don't order before: ${NOT_BEFORE}"

[[ -f next-orders.txt ]] && echo "File for next orders found" || touch next-orders.txt
[[ -f sent-orders.txt ]] && echo "File for sent orders found" || touch sent-orders.txt

if [[ `tail -1 next-orders.txt` < $CURRENT_DATE ]];then
	curl -H "Authorization: Bearer ${WEBHOOK_TOKEN}" \
		-X POST \
		"${WEBHOOK_URL}" \
		--data "order-date=${CURRENT_DATE}"
	if [[ $? == 0 ]];then
		echo "\n$NOT_BEFORE" > next-orders.txt
		echo "\n$CURRENT_DATE" > sent-orders.txt
	else
		echo "Something went wrong!"
	fi
else
	echo "Don't!!"
fi

