# Makefile to build a self-extracting archive of
# chkhosts.sh and supporting files.

PACKAGEFILES:=../chkhosts.sh \
	../chkhosts-sample.d/conf/hostlist.txt \
	../chkhosts-sample.d/conf/notify-email.txt \
	../chkhosts-sample.d/conf/notify-sms.txt \
	../chkhosts-sample.d/log/ \
	../chkhosts-sample.d/status-down/ \
	../chkhosts-sample.d/status-up/
BUILDDIR=./build
SHORT_SHA:=$(shell git rev-parse --short HEAD)
VERSION_STRING?=v1.0.0 (git-$(SHORT_SHA))

tarball:	
	cp install.hdr.in install.hdr 
	sed -i 's/MY_VERSION_STRING/$(VERSION_STRING)/g' install.hdr
	mkdir -p $(BUILDDIR)
	cp -r ../chkhosts-sample.d/ $(BUILDDIR)/
	cp ../chkhosts.sh $(BUILDDIR)/
	( cd $(BUILDDIR); \
	sed -i 's/MY_VERSION_STRING/$(VERSION_STRING)/g' chkhosts.sh; \
	tar czf ../files.tz *)
	cat install.hdr files.tz > install-chkhosts.sh
	rm -f files.tz install.hdr
	chmod 755 install-chkhosts.sh
	
clean:
	rm -rf $(BUILDDIR)
	rm -f install-chkhosts.sh files.tz install.hdr
