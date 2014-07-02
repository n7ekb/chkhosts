#!/bin/bash
#
# Script to determine host status.
#
# usage:  chkhosts  working_directory
#


# Configure which E-mail client is to be used for sending e-mail/SMS alerts
EMAIL_CLIENT=mutt

# Announce ourselves.
echo "Check Hosts MY_VERSION_STRING"

# Check for required parameter and grab our working directory
if [[ "$#" -ne "1" ]]; then
        echo ""
        echo "ERROR:  Must specify working directory."
        echo ""
        exit 1
else
	WORKDIR=$1
fi

# Now set our variables relative to the working directory
HOSTLISTFILE=$WORKDIR/conf/hostlist.txt
EMAIL_LIST=$WORKDIR/conf/notify-email.txt
SMS_LIST=$WORKDIR/conf/notify-sms.txt
UPHOSTSTATUSDIR=$WORKDIR/status-up
DOWNHOSTSTATUSDIR=$WORKDIR/status-down
CHKHOSTLOGDIR=$WORKDIR/log
CHKHOSTLOG=$CHKHOSTLOGDIR/chkhosts.log


# our logging function
_log () {
        # prepend everything with date & time stamp & write message to log
        echo "`date +"%F %T"`: $1" >>$CHKHOSTLOG
}


# our e-mail notification function 
# usage:  _notify_email  <shortname>  <longname>
_notify_email () {
	for j in $( grep -v -e '^#' $EMAIL_LIST ); do
		echo "   Notifying $j that $2 is $3"
		echo "$2 is $3" | \
		$EMAIL_CLIENT -s "Host status: $1 $3" "$j" ;
	done
}


# our SMS notification function  (done via e-mail gateway for now)
# usage:  _notify_sms  <shortname>  <longname>
_notify_sms () {
	for j in $( grep -v -e '^#' $SMS_LIST ); do
		echo "   Notifying $j that $2 is $3"
		echo "$2 is $3" | \
		$EMAIL_CLIENT -s "$1 $3" "$j" ;
	done
}


#
# Check on hosts in our HOSTLISTFILE...
#
for i in $( grep -v -e '^#' $HOSTLISTFILE ); do

	# create short host name...
	IPADDR="`echo $i | grep -e '[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*'`"
	if [[ "$IPADDR" == "" ]]; then
		SHORTNAME="`echo $i | awk -F . '{ print $1}'`"
	else
		SHORTNAME="$IPADDR"
	fi

	# ping the host with one packet...
	ping -q -c 1 $i >/dev/null 2>&1

	# do a single re-ping if no answer to avoid false positive
	# on flaky network, really busy host, etc.	
	if [[ "$?" != "0" ]]; then
		echo "Host $i didn't respond to first ping.  Re-pinging."
		ping -q -c 1 $i >/dev/null 2>&1
	fi

	# now act on ping results 
	if [[ "$?" != "0" ]]; then
		#
		# Ping was not returned - dead host?
		#
		if [ -e "$DOWNHOSTSTATUSDIR/$i" ]; then
			echo "Host $i is still down or unreachable."
			rm -f "$UPHOSTSTATUSDIR/$i"
		else
			echo "Host $i is down or unreachable."
			_log "Host $i is down or unreachable."
			touch "$DOWNHOSTSTATUSDIR/$i"
			rm -f "$UPHOSTSTATUSDIR/$i"
			_notify_sms "$SHORTNAME" "$i" "down"
			_notify_email "$SHORTNAME"  "$i" "down"
		fi
	else
		#
		# Ping was returned - host is alive
		#
		if [ -e "$UPHOSTSTATUSDIR/$i" ]; then
			echo "Host $i is still up."
			touch "$UPHOSTSTATUSDIR/$i"
		else
			echo "Host $i just came back up."
			_log "Host $i came back up."
			touch "$UPHOSTSTATUSDIR/$i"
			rm -f "$DOWNHOSTSTATUSDIR/$i"
			_notify_sms "$SHORTNAME" "$i" "up"
			_notify_email "$SHORTNAME"  "$i" "up"
		fi
	fi
done
exit 0
