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

python led_boot.py

echo "Current date and time is : ${CURRENT_DATE}"
echo "Don't order before: ${NOT_BEFORE}"

[[ -f next-orders.cb ]] && echo "File for next orders found" || touch next-orders.cb
[[ -f sent-orders.cb ]] && echo "File for sent orders found" || touch sent-orders.cb
[[ -f logfile.txt ]] && echo "Logs file found" || touch logfile.txt

if [[ `tail -1 next-orders.cb` < $CURRENT_DATE ]];then
	curl -H "Authorization: Bearer ${WEBHOOK_TOKEN}" \
		-X POST \
		"${WEBHOOK_URL}" \
		--data "order-date=${CURRENT_DATE}"
	if [[ $? == 0 ]];then
		echo "\n$NOT_BEFORE" > next-orders.cb
		echo "\n$CURRENT_DATE" > sent-orders.cb
		echo "`date` -- Command sent\n" > logfile.txt
		python led_ok.py
	else
		echo "`date` -- Something went wrong!" > logfile.txt
		python led_ko.py
	fi
else
	echo "`date` -- Order already placed" > logfile.txt
	python led_ok.py
fi

sudo power off
