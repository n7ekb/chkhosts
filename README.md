chkhosts
========

Simple host monitoring

Chkhosts is a package designed to run on a PHP-enabled Linux/Unix web
server, providing visual status of a group of systems via a dynamic 
web status page.  

The chkhosts web status page displays a table with a cell for each 
system that is being monitored.  The cell for each system is labeled
by the system's hostname.  If a text file named "hostname.txt" (replace 
hostname with the corresponding system hostname) exists in the chkhosts
"system-info" sub-directory, the hostname label on the status page will
be a link to the file.  The contents of this "hostname.txt" file can be 
anything.  Typically the corresponding hostname.txt file for a system
will contain detailed system information that the host generates itself
such as BIOS revision, memory configuration, etc.  A system administrator
can configure the monitored host(s) to create this file and then copy it 
to the chkhosts server at boot time or some periodic interval.

The chkhosts package includes a crontab-driven script that does periodic 
network pings of the monitored systems.  This "ping" script updates 
status files used by the chkhosts system status web page to color the 
background indicating status.  Default is "red" for host down, "green" 
for host up.  If a host is up, the default background of green can 
optionally be overriden with a different color by putting a valid 
HTML color name (or hex value) in a "hostname".txt file in the chkhosts 
"system-color" sub-directory.  The web status page will then use this 
background color for the cell representing the corresponding system in 
its status table.

Changes in a system's status detected by the "ping" script are 
logged (system up/system down) and a link to this log is provided 
on the chkhosts web status page.  

Additional lines are displayed in the cell for each monitored system.
The second line, referred to as the "comment" line, has an associated 
web form page that allows web users to enter a display text for the line.  
When a web user submits a change to the comment line, the text submitted
is logged along with the date and time in the corresponding "comment" log 
file.  A link to this log file is provided on the chkhosts web status page.
The comment line is typically used to help coordinate the usage of shared 
systems in a workgroup or to log changes being made to the systems being 
monitored.

The remaining lines in the cell for each monitored system, lines 3
through 8, are optional, and only appear if there is a text file 
"hostname.txt" corresponding to the monitored host name in the 
chkhosts "system-lineX" sub-directories.  The contents of the 
hostname.txt file is displayed for the corresponding line for a 
system if it is present. 

