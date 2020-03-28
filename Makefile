CFLAGS=-Wall -fPIC -ansi -pedantic
LIBDIR=/lib

ifeq ($(shell if uname -o | grep -q "GNU/Linux" ; then echo true; else echo false; fi),true)
    ifeq ($(shell if [ -e /etc/debian_version ] ; then echo true; else echo false; fi),true)
	DEB_HOST_MULTIARCH ?= $(shell dpkg -L libc6 | sed -nr 's|^/etc/ld\.so\.conf\.d/(.*)\.conf$$|\1|p')
	ifneq ($(DEB_HOST_MULTIARCH),)
	    LIBDIR=/lib/$(DEB_HOST_MULTIARCH)
	endif
    else ifeq ($(shell uname -m),x86_64)  # redhat?
	LIBDIR=/lib64
    endif
endif

PAM_DIR=$(LIBDIR)/security

CWD := $(abspath $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST))))))
RPM_DEST_DIR=$(CWD)/build/rpms
VERSION=0.1

all: pam_oauth2.so

pam_oauth2.so: pam_oauth2.o
	$(CC) -shared $^ -lcurl -lpam -o $@

install: pam_oauth2.so
	install -d $(DESTDIR)$(PAM_DIR)
	install -m 644 $< $(DESTDIR)$(PAM_DIR)

rpm: pam_oauth2.so rpm_pam_oauth2.spec
	rm -rf $(CWD)/build 
	mkdir -p $(CWD)/build/pam_oauth2-${VERSION} $(CWD)/build/rpmbuild/SOURCES ${RPM_DEST_DIR} 
	cp $(CWD)/pam_oauth2.so $(CWD)/build/pam_oauth2-${VERSION}/
	tar -czf $(CWD)/build/rpmbuild/SOURCES/pam_oauth2-${VERSION}.tar.gz -C $(CWD)/build pam_oauth2-${VERSION}
	rpmbuild -ba "-D ver ${VERSION}" "-D _topdir $(CWD)/build/rpmbuild" $(CWD)/rpm_pam_oauth2.spec
	mv $(CWD)/build/rpmbuild/RPMS/x86_64/*.rpm ${RPM_DEST_DIR}/

clean:
	$(MAKE) -C jsmn clean
	rm -rf *.o *.so $(CWD)/build
