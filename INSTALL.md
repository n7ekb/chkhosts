chkhosts Build
==============

Obtain the latest copy of chkhosts from here:

    https://github.com/k6ekb/chkhosts

Change to the directory where you have cloned/unpacked the chkhosts
source.  You'll find several directories including the "install-pkg"
sub-directory.  If you change into the "install-pkg" directory
and execute the "make" command, it will build a fresh, self-extracting
bash shell archive called "install-chkhosts.sh".  This file is all
you need to install chkhosts on a system.

The Makefile provided also has a "clean" target which will remove the
build directory and related files.


chkhosts Installation
=====================

Chkhosts was developed on a CentOS Linux system running an Apache
web server with PHP installed.  It should run on any modern Linux
distribution - feedback to the development team would be greatly 
appreciated if you find a system it won't run on.

Before installing, you should identify the system that will be hosting
the dynamic chkhosts web status page.  In the simplest configuration, 
this web server system will host the chkhosts web status page and also 
run the chkhosts "ping" script from a crontab entry.  

The install script ("install-chkhosts.sh") requires one argument
when executed - the name of the directory where the executable
chkhosts scripts should be installed.  When the install script runs,
it will create a "chkhosts-sample.d" sub-directory in its current 
working directory.  This sub-directory contains all of the data and
configuration files associated with chkhosts.


Installation Example
====================

In this example, the web server's root directory is "/var/www/html" 
and the chkhosts executable scripts are going to be installed in
"/usr/local/bin".  It's assumed that the "install-chkhosts.sh" script 
has been placed in the "/var/www/html" directory.

     cd /var/www/html
     sudo ./install-chkhosts.sh  /usr/local/bin


chkhosts Configuration
======================


