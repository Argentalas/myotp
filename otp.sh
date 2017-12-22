#!/bin/bash

function usage {
	echo "
Usage:
$0 <service>
"
}

if ! which oathtool > /dev/null; then
	echo "
oathtool package missing

<your_package_manager> install oathtool
This requires EPEL repo on CentOS.
This requires brew on MacOS."
	exit 1
fi

if [ ! -f ~/.otp ]; then
	printf "example\tg4g3xan4qpi4ph57" >> ~/.otp
	chmod 600 ~/.otp
	echo "
Hello!
Keystore file created as ~/.otp
You can add tokens there via a text editor as follows:
example njc2kj34knbkjf8v"
	exit 0
fi

if [ $# -eq 0 ]; then
	echo
	echo "No argument provided"
	usage
	exit 2
fi

SECRET_LINE=$(grep $1 ~/.otp) 

SEC_LINE_LEN=$(wc -w <<< $SECRET_LINE)

if [ $SEC_LINE_LEN -gt 2 ]; then
	echo "
Ambiguous input.

Or malformed ~/.otp"
	exit 3
fi

if [ $SEC_LINE_LEN -lt 2 ];then
	echo
	echo "Could not retrieve token for \"$1\""
	usage
	exit 4
fi

SERVICE=$(awk '{print $1}' <<< $SECRET_LINE)
SECRET=$(awk '{print $2}' <<< $SECRET_LINE)

CODE=$(oathtool --totp -b $SECRET)

echo $CODE | pbcopy
echo $SERVICE
echo "$CODE (Copied to clipboard)"

SECONDS=$(date "+%S")
(( TIME_REMAINING = 30 - (10#$SECONDS % 30) ))

tput sc
while [[ $TIME_REMAINING -gt 0 ]]; do
	tput rc
	printf "Time remaining $((--TIME_REMAINING)) "
	sleep 1
done

echo
