# Makefile to build a self-extracting archive of
# chkhosts.sh and supporting files.

PACKAGEFILES:=../scripts/chkhosts.sh \
	../scripts/chkhosts-gen-webstat.sh \
	../chkhosts-sample.d/conf/chkhosts.conf \
	../chkhosts-sample.d/conf/chkhosts-gen-webstat.conf \
	../chkhosts-sample.d/conf/hostlist.txt \
	../chkhosts-sample.d/conf/notify-email.txt \
	../chkhosts-sample.d/conf/notify-sms.txt \
	../chkhosts-sample.d/log/ \
	../chkhosts-sample.d/status-down/ \
	../chkhosts-sample.d/status-up/
BUILDDIR=./build
GIT_DESCRIBE:=$(shell git describe --abbrev=7 --dirty --always --tags)
VERSION_STRING?=v1.3.0 (git: $(GIT_DESCRIBE))

tarball:	
	cp install.hdr.in install.hdr 
	sed -i 's/MY_VERSION_STRING/$(VERSION_STRING)/g' install.hdr
	mkdir -p $(BUILDDIR)
	cp -r ../chkhosts-sample.d/ $(BUILDDIR)/
	cp ../scripts/chkhosts.sh $(BUILDDIR)/
	cp ../scripts/chkhosts-gen-webstat.sh $(BUILDDIR)/
	( cd $(BUILDDIR); \
	sed -i 's/MY_VERSION_STRING/$(VERSION_STRING)/g' chkhosts.sh; \
	sed -i 's/MY_VERSION_STRING/$(VERSION_STRING)/g' \
		chkhosts-gen-webstat.sh; \
	tar czf ../files.tz *)
	cat install.hdr files.tz > install-chkhosts.sh
	rm -f files.tz install.hdr
	chmod 755 install-chkhosts.sh
	
clean:
	rm -rf $(BUILDDIR)
	rm -f install-chkhosts.sh files.tz install.hdr
