#! /bin/bash -e

# This script is supposed to:
# - check the date and compare to the last usage of the button
# - if more than 48h as passed since last use, send a POST request using curl to Zappier URL
# - this request contains an Authorization header and the current date
# - it then needs to shutdown the device
SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# Files and directory check and/or creation
[[ -d /etc/coffee-button ]] && echo "Directory exists" \
	|| (mkdir -p /etc/coffee-button && echo "Directory created")
FILE_DIR="/etc/coffee-button"
[[ -f ${FILE_DIR}/.env ]] && echo "Env file found" \
	|| (cp /home/pi/coffee-button/.env ${FILE_DIR} && echo "Env file copied from last commit")
[[ -f ${FILE_DIR}/next-orders.cb ]] && echo "File for next orders found" \
	|| (touch ${FILE_DIR}/next-orders.cb && echo "File for next orders created")
[[ -f ${FILE_DIR}/sent-orders.cb ]] && echo "File for sent orders found" \
	|| (touch ${FILE_DIR}/sent-orders.cb && echo "File for sent orders created")
[[ -f ${FILE_DIR}/logfile.log ]] && echo "Logs file found" \
	|| (touch ${FILE_DIR}/logfile.log && echo "Log file created")

# Importing env and testing duration value
source ${FILE_DIR}/.env
REGEXP='^[0-9]+$'
if ! [[ $DURATION_IN_DAYS =~ $REGEXP ]] ; then
	echo "Error: Duration in days is not a number" >> ${FILE_DIR}/logfile.log
	python ${SCRIPTPATH}/led_ko.py
	exit 1
fi

CURRENT_DATE=$(date +"%F-%H:%M")
NOT_BEFORE=$(date -d "+$DURATION_IN_DAYS days" +"%F-%H:%M")

python ${SCRIPTPATH}/led_boot.py

echo "Current date and time is : ${CURRENT_DATE}"
echo "Don't order before: ${NOT_BEFORE}"

if [[ $(tail -1 ${FILE_DIR}/next-orders.cb) < $CURRENT_DATE ]];then
	curl -H "Authorization: Bearer ${WEBHOOK_TOKEN}" \
		-X POST \
		"${WEBHOOK_URL}" \
		--data "order-date=${CURRENT_DATE}"
	if [[ $? == 0 ]];then
		printf "\n$NOT_BEFORE" > ${FILE_DIR}/next-orders.cb
		printf "\n$CURRENT_DATE" > ${FILE_DIR}/sent-orders.cb
		echo "$(date) -- Command sent\n" >> ${FILE_DIR}/logfile.log
		python ${SCRIPTPATH}/led_ok.py
	else
		echo "$(date) -- Something went wrong!" >> ${FILE_DIR}/logfile.log
		python ${SCRIPTPATH}/led_ko.py
	fi
else
	echo "$(date) -- Order already placed" >> ${FILE_DIR}/logfile.log
	curl -H "Authorization: Bearer ${WEBHOOK_TOKEN}" \
		-X POST \
		"${WEBHOOK_URL}" \
		--data "last-logs=$(tail ${FILE_DIR}/logfile.log)"
	python ${SCRIPTPATH}/led_ok.py
fi

sudo poweroff

