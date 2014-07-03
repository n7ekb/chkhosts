#!/bin/bash
#
# Script to generate host status php web page and
# the comment update form page.
#
# usage: gen-webstat.sh  chkhosts_directory


# Variables to customize the output page
_CHKHOSTS_TITLE_="Chkhosts System Status"
_CHKHOSTS_FORMTITLE_="Chkhosts System Comment Update"
_CHKHOSTS_HOSTNAME_="chkhost.somwhere.com"
_CHKHOSTS_POLL_INTERVAL_="5 minute"
_CHKHOSTS_CONTACTNAME_="John Doe"
_CHKHOSTS_CONTACTEMAIL_="john.doe@somewhere.com"
_CHKHOSTS_TABLE_COLS_="3"

# Announce ourselves.
echo "Gen-webstat.sh MY_VERSION_STRING"

# Check for required parameter and grab our working directory
if [[ "$#" -ne "1" ]]; then
        echo ""
        echo "ERROR:  Must specify chkhost's working directory."
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
WEBSTATDIR=$WORKDIR/webstat
WEBDESCRIPTIONDIR=$WEBSTATDIR/system-description
WEBCOMMENTDIR=$WEBSTATDIR/system-comment
WEBPAGE=$WEBSTATDIR/status.php
FORMPAGE=$WEBSTATDIR/update-comment.php

# Calculate the number of hosts we're monitoring
NUMSYSTEMS=$(grep -v -e '^#' $HOSTLISTFILE | wc -l)


#
# Create the Comment Form page first
####################################

echo '<!DOCTYPE html>' >$FORMPAGE
echo '<html>'  >>$FORMPAGE
echo '<head>'  >>$FORMPAGE
echo '	<meta charset="UTF-8">' >>$FORMPAGE
echo '	<meta http-equiv="refresh" content="300">' >>$FORMPAGE
echo '	<meta name="generator" content="gen-webstat.sh MY_VERSION_STRING">' \
	>>$FORMPAGE
echo '	<link rel="stylesheet" type="text/css" href="style.css">' >>$FORMPAGE
echo "	<title>${_CHKHOSTS_FORMTITLE_}</title>"   >>$FORMPAGE
echo '</head>' >>$FORMPAGE
echo ' ' >>$FORMPAGE

echo '<body>' >>$FORMPAGE

# insert the php POST function and showstatus functions
cat >>$FORMPAGE << "SUBMIT_FUNCTION_SECTION"
<?php
	session_start();
	if (isset($_SESSION['comment_session'])) {
		/* Don't do anything - already processed the submit... */
	}
	else {
        	if (isset($_POST['submit'])) {
               		$action_hostname = $_POST['CommentHostName'];
                	$action_comment = $_POST['CommentText'];
                	file_put_contents("system-comment/$action_hostname.txt",
				$action_comment);
                	$log_entry = strftime("%F %T: ") . 
				"$action_hostname, $action_comment\n";
                	file_put_contents("comment.log",$log_entry, 
				FILE_APPEND);
			header('Location: status.php');
			exit();
		}
        }
?>
SUBMIT_FUNCTION_SECTION

# insert the comment section 
cat >>$FORMPAGE << "COMMENT_SECTION_1"

<p>
To help coordinate access to the systems, you can change the comment
to a host's status cell by using the following form:
</p>
<form action="<?php echo $_SERVER['PHP_SELF']; ?>" method="post">
<table align="center" style="border-spacing: 1px;border-style: solid;
              border-color: #000000;border-width: 3px 3px 3px 3px">
        <tr><td><b>Host:</b> &nbsp;
                <select name="CommentHostName">
                        <option selected value="unknown">&lt;select host&gt;
COMMENT_SECTION_1

# setup the system-comment and system-description directories and
mkdir -p $WEBCOMMENTDIR
mkdir -p $WEBDESCRIPTIONDIR
echo -n "" >$WEBSTATDIR/comment.log
for i in $( grep -v -e '^#' $HOSTLISTFILE ); do

	# create short host name...
        IPADDR="`echo $i | grep -e '[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*'`"
        if [[ "$IPADDR" == "" ]]; then
                SHORTNAME="`echo $i | awk -F . '{ print $1}'`"
        else
                SHORTNAME="$IPADDR"
	fi

	# add to list in web page
	echo "		<option value=\"$SHORTNAME\">$SHORTNAME" >>$FORMPAGE

	# add initial comment to comment file for host
	echo "description" >$WEBDESCRIPTIONDIR/$SHORTNAME.txt

	# add initial comment to comment file for host
	echo "no comment" >$WEBCOMMENTDIR/$SHORTNAME.txt
done

# set permissions so web server can write the files
chmod ugo+w $WEBCOMMENTDIR/* $WEBDESCRIPTIONDIR/* $WEBSTATDIR/comment.log

cat >>$FORMPAGE << "COMMENT_SECTION_2"
                </select>
                </td></tr>
        <tr><td><b>Comment:</b> &nbsp;
                <input type="text" name="CommentText" size=40 maxlength=512 /></td></tr>
        <tr><td align="center"><input type="submit" name="submit" value="Update Comment"></td></tr>
</table>
</form>
COMMENT_SECTION_2

#
# Close out FORMPAGE document 
#############################

echo '</body>' >>$FORMPAGE
echo '</html>' >>$FORMPAGE

# now customize the Comment Form page...
sed -i "s/_CHKHOSTS_FORMTITLE_/${_CHKHOSTS_FORMTITLE_}/g" $FORMPAGE
sed -i "s/_CHKHOSTS_HOSTNAME_/${_CHKHOSTS_HOSTNAME_}/g" $FORMPAGE
sed -i "s/_CHKHOSTS_POLL_INTERVAL_/${_CHKHOSTS_POLL_INTERVAL_}/g" $FORMPAGE
sed -i "s/_CHKHOSTS_CONTACTNAME_/${_CHKHOSTS_CONTACTNAME_}/g" $FORMPAGE
sed -i "s/_CHKHOSTS_CONTACTEMAIL_/${_CHKHOSTS_CONTACTEMAIL_}/g" $FORMPAGE



#
# Generate the HTML header
##########################

echo '<!DOCTYPE html>' >$WEBPAGE
echo '<html>'  >>$WEBPAGE
echo '<head>'  >>$WEBPAGE
echo '	<meta charset="UTF-8">' >>$WEBPAGE
echo '	<meta http-equiv="refresh" content="300">' >>$WEBPAGE
echo '	<meta name="generator" content="gen-webstat.sh MY_VERSION_STRING">' \
	>>$WEBPAGE
echo '	<link rel="stylesheet" type="text/css" href="style.css">' >>$WEBPAGE
echo "	<title>${_CHKHOSTS_TITLE_}</title>"   >>$WEBPAGE
echo '</head>' >>$WEBPAGE
echo ' ' >>$WEBPAGE

#
# Generate the HTML body
########################

echo '<body>' >>$WEBPAGE

# insert the php POST function and showstatus functions
cat >>$WEBPAGE << "PHP_FUNCTIONS_SECTION"
<?php
        date_default_timezone_set('America/Los_Angeles');
        function showstatus($pingname,$hostname)
        {
                if (file_exists("../status-up/$pingname")) {
                        echo '<td style="background-color:green; \
				border-color: #000000; \
				border-width: 1px 1px 1px 1px">';
                        echo "<b>$hostname</b><br>";
                        echo "$pingname<br>";
                        if (file_exists("system-description/$hostname.txt")) {
                                $description=rtrim(file_get_contents(
					"system-description/$hostname.txt"));
                                echo $description;
                                echo "<br>";
                        }
                        if (file_exists("system-comment/$hostname.txt")) {
                                $comment=rtrim(file_get_contents(
					"system-comment/$hostname.txt"));
                                echo $comment;
                                echo "<br>";
                        }
                        echo strftime("%Y-%m-%d at %H:%M %Z",
                                filemtime("../status-up/$pingname"));
                        echo '</td>';
                } else {
                        echo '<td style="background-color:red; \
				border-color: #000000; \
				border-width: 1px 1px 1px 1px">';
                        echo "<b>$hostname</b><br>";
                        echo "$pingname<br>";
                        if (file_exists("system-description/$hostname.txt")) {
                                $description=rtrim(file_get_contents(
					"system-description/$hostname.txt"));
                                echo $description;
                                echo "<br>";
                        }
                        if (file_exists("system-comment/$hostname.txt")) {
                                $comment=rtrim(file_get_contents(
					"system-comment/$hostname.txt"));
                                echo $comment;
                                echo "<br>";
                        }
                        if (file_exists("../status-down/$pingname")) {
                                echo strftime("%Y-%m-%d at %H:%M %Z",
                                        filemtime("../status-down/$pingname"));
                        } else {
                                echo "pinging halted";
                        }
                        echo '</td>';
                }
        }
?>

PHP_FUNCTIONS_SECTION

# insert the header and intro section template
cat >>$WEBPAGE  << "HEADER_INTRO_SECTION"

<div class="body">

<h1 class="title">_CHKHOSTS_TITLE_</h1>
<p align=center><b><?php echo "Last refreshed: ";
                        echo strftime('%c'); ?></b></p>

<p>
The date and time in the bottom of each cell in the tables below is the
time the host <b>last</b> responded to a network ping. &nbsp;
The ping script runs on _CHKHOSTS_HOSTNAME_ 
<b>at a _CHKHOSTS_POLL_INTERVAL_ interval</b> 
and sends text/SMS and e-mail notifications when systems first 
go down or come back up. &nbsp;
Contact <a href="mailto:_CHKHOSTS_CONTACTEMAIL_">_CHKHOSTS_CONTACTNAME_</a>
if you'd like to be added to the SMS or e-mail
notification lists.
</p>

HEADER_INTRO_SECTION

# insert the status table
echo "<h3>System Status Table ($NUMSYSTEMS systems)</h3>" >>$WEBPAGE
echo '<p><table>' >>$WEBPAGE

HOSTCOUNTER=0
for i in $( grep -v -e '^#' $HOSTLISTFILE ); do

	# create short host name...
        IPADDR="`echo $i | grep -e '[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*'`"
        if [[ "$IPADDR" == "" ]]; then
                SHORTNAME="`echo $i | awk -F . '{ print $1}'`"
        else
                SHORTNAME="$IPADDR"
        fi

	# start a new table row 	
	if [[ "$((HOSTCOUNTER % $_CHKHOSTS_TABLE_COLS_))" == "0" ]]; then
		echo '<tr>' >>$WEBPAGE
	fi
	echo "<?php showstatus(\"$i\",\"$SHORTNAME\"); ?>" >>$WEBPAGE

	let "HOSTCOUNTER += 1"
done
echo '</table></p>' >>$WEBPAGE


# insert the Log links section 
cat >>$WEBPAGE << "LOG_SECTION"
<p>
Click <a href="update-comment.php"><b>here</b></a> to update the 
comment for a host. &nbsp;  
The comment is line four in the host's status cell in the 
system status table above.
</p>
<p>
<a href="../log/chkhosts.log"><b>Status change log file</b>.</a>
</p>
<p>
<a href="comment.log"><b>Comment change log file</b>.</a> &nbsp;
</p>
<p>
Windows users:  The log file links above render best in Google 
Chrome or Firefox; 
Internet Explorer reportedly garbles or doesn't display the 
log file at all.
</p>
LOG_SECTION


# insert the footer
cat >>$WEBPAGE << "FOOTER_SECTION"
</div>

<div class="footer"> 
      <hr width="55%">
      <p align="center">This page generated by 
	<a href="https://github.com/k6ekb/chkhosts">
	gen-webstat.sh MY_VERSION_STRING</a><br>
	This page last edited on 
	<?php echo  strftime("%a, %d %b %Y at %H:%M %Z.", 
		filemtime("status.php")); ?><br>
        You're logged in as '<?php print getenv("REMOTE_USER");?>' 
	from <?php print getenv("REMOTE_ADDR"); ?><br>
</div>
FOOTER_SECTION

#
# Close out document 
####################

echo '</body>' >>$WEBPAGE
echo '</html>' >>$WEBPAGE


# now customize it...
sed -i "s/_CHKHOSTS_TITLE_/${_CHKHOSTS_TITLE_}/g" $WEBPAGE
sed -i "s/_CHKHOSTS_HOSTNAME_/${_CHKHOSTS_HOSTNAME_}/g" $WEBPAGE
sed -i "s/_CHKHOSTS_POLL_INTERVAL_/${_CHKHOSTS_POLL_INTERVAL_}/g" $WEBPAGE
sed -i "s/_CHKHOSTS_CONTACTNAME_/${_CHKHOSTS_CONTACTNAME_}/g" $WEBPAGE
sed -i "s/_CHKHOSTS_CONTACTEMAIL_/${_CHKHOSTS_CONTACTEMAIL_}/g" $WEBPAGE

# all done!
exit 0
