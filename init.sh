#! /bin/bash -e

# This script is supposed to:
# - check the date and compare to the last usage of the button
# - if more than 48h as passed since last use, send a POST request using curl to Zappier URL
# - this request contains an Authorization header and the current date
# - it then needs to shutdown the device
SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source ${SCRIPTPATH}/.env

CURRENT_DATE=$(date +"%F-%H:%M")
NOT_BEFORE=$(date -d +2d +"%F-%H:%M")

python ${SCRIPTPATH}/led_boot.py

echo "Current date and time is : ${CURRENT_DATE}"
echo "Don't order before: ${NOT_BEFORE}"

[[ -f next-orders.cb ]] && echo "File for next orders found" || touch next-orders.cb
[[ -f sent-orders.cb ]] && echo "File for sent orders found" || touch sent-orders.cb
[[ -f logfile.log ]] && echo "Logs file found" || touch logfile.log

if [[ $(tail -1 next-orders.cb) < $CURRENT_DATE ]];then
	curl -H "Authorization: Bearer ${WEBHOOK_TOKEN}" \
		-X POST \
		"${WEBHOOK_URL}" \
		--data "order-date=${CURRENT_DATE}"
	if [[ $? == 0 ]];then
		printf "\n$NOT_BEFORE" > next-orders.cb
		printf "\n$CURRENT_DATE" > sent-orders.cb
		echo "$(date) -- Command sent\n" >> logfile.log
		python ${SCRIPTPATH}/led_ok.py
	else
		echo "$(date) -- Something went wrong!" >> logfile.log
		python ${SCRIPTPATH}/led_ko.py
	fi
else
	echo "$(date) -- Order already placed" >> logfile.log
	python ${SCRIPTPATH}/led_ok.py
fi

sudo power off
