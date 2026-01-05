#*
#* CU sudo version 1.3.1 (based on Root Group sudo version 1.1)
#*
#* This software comes with no waranty whatsoever, use at your own risk.
#*
#* Please send bugs, changes, problems to sudo-bugs.cs.colorado.edu
#*

#*  sudo version 1.1 allows users to execute commands as root
#*  Copyright (C) 1991  The Root Group, Inc.
#*
#*  This program is free software; you can redistribute it and/or modify
#*  it under the terms of the GNU General Public License as published by
#*  the Free Software Foundation; either version 1, or (at your option)
#*  any later version.
#*
#*  This program is distributed in the hope that it will be useful,
#*  but WITHOUT ANY WARRANTY; without even the implied warranty of
#*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#*  GNU General Public License for more details.
#*
#*  You should have received a copy of the GNU General Public License
#*  along with this program; if not, write to the Free Software
#*  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#*

#### Start of system configuration section. ####

srcdir = .
VPATH = .

# Compiler & tools to use
CC = cc
LEX = lex
YACC = yacc
NROFF = nroff

# Which install program?
INSTALL = install

# Libraries
LIBS = 

# OS defines
OSDEFS = 

# Usually -g or -O
# On PDP-11, don't use -O as it makes the code larger
CFLAGS = 

# How to make a static binary
# Use -i for split I&D space on PDP-11 (separate 64KB instruction + data spaces)
LDFLAGS = -i 

# Where to install things...
prefix = /usr/local
exec_prefix = $(prefix)
man_prefix = /usr/man

# Directory in which to install sudo.
sudodir = /bin

# Directory in which to install visudo
visudodir = /sbin

# Directory in which to install the sudoers file
sudoersdir = /etc

# Directory in which to install the man page
mantype = cat
manpage = sudo.$(mantype)
mansect = 8
mandir = $(man_prefix)/$(mantype)$(mansect)

# User and Group the installed file should be owned by
owner = root
group = staff

# See sudo.h for a list of options
# Disable features to reduce code size on PDP-11:
# Set MAILER to /bin/true to prevent mail sending
# Reduce buffer sizes for PDP-11
OPTIONS = -DMAILER=\"/bin/true\" -USEND_MAIL_WHEN_NO_USER -USEND_MAIL_WHEN_NOT_OK -DMAXLOGLEN=512

#### End of system configuration section. ####

SHELL = /bin/sh

# Only build sudo, not visudo (visudo is too complex for PDP-11)
# To try building visudo, change this to: PROGS = sudo visudo
PROGS = sudo visudo

SRCS = check.c find_path.c logging.c parse.c sudo.c sudo_realpath.c \
       sudo_setenv.c visudo.c parse.yacc parse.lex

OBJS = check.o find_path.o logging.o parse.o sudo.o sudo_realpath.o \
       sudo_setenv.o y.tab.o lex.yy.o

VISUDO_OBJS = visudo.o y.tab.o lex.yy.o parse.o find_path.o logging.o sudo_setenv.o sudo_realpath.o check.o visudo_stubs.o

LIBOBJS = tgetpass.o getwd.o strdup.o

HDRS = sudo.h version.h insults.h

DISTFILES = $(SRCS) $(HDRS) BUGS CHANGES COPYING INSTALL Makefile.in PORTING \
            README README.v1.3.1 SUPPORTED TODO aclocal.m4 getcwd.c putenv.c \
            strdup.c tgetpass.c config.h.in configure configure.in indent.pro \
	    installbsd pathnames.h.in sample.sudoers sudo.man sudo.cat sudoers \
	    aixcrypt.exp visudoers/Makefile.in visudoers/config.h \
	    aixcrypt.exp visudoers/Makefile.in visudoers/config.h \
	    visudoers/pathnames.h visudoers/sudo.h visudoers/version.h \
	    visudoers/visudo.c visudoers/visudo.lex visudoers/visudo.yacc \
	    visudoers/aixcrypt.exp

all: $(PROGS)

.SUFFIXES: .o .c .h .lex .yacc .man .cat

.c.o:
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $(OSDEFS) $(OPTIONS) -I$(srcdir) $<

.man.cat:
	$(NROFF) -man $< > $@

sudo : $(OBJS) $(LIBOBJS)
	$(CC) -o $@ $(OBJS) $(LIBOBJS) $(LDFLAGS) $(LIBS)

# Alternative with overlays for PDP-11 if too large
# Overlay the parser (y.tab.o lex.yy.o) with other modules
sudo-overlay : $(OBJS) $(LIBOBJS)
	$(CC) -o sudo check.o find_path.o logging.o parse.o sudo.o sudo_realpath.o sudo_setenv.o $(LIBOBJS) -Z y.tab.o lex.yy.o $(LDFLAGS) $(LIBS)

# More aggressive overlays - split into multiple overlay groups
sudo-overlay2 : $(OBJS) $(LIBOBJS)
	$(CC) -o sudo sudo.o $(LIBOBJS) -i -Z check.o find_path.o -Z logging.o parse.o -Z sudo_realpath.o sudo_setenv.o y.tab.o lex.yy.o $(LIBS)

visudo : $(VISUDO_OBJS) $(LIBOBJS)
	$(CC) -o $@ $(VISUDO_OBJS) $(LIBOBJS) $(LDFLAGS) $(LIBS)

y.tab.o y.tab.h: parse.yacc $(HDRS)
	$(YACC) -d parse.yacc
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $(OSDEFS) $(OPTIONS) -I$(srcdir) y.tab.c

lex.yy.o: parse.lex y.tab.h $(HDRS)
	$(LEX) parse.lex
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $(OSDEFS) $(OPTIONS) -I$(srcdir) lex.yy.c

$(OBJS) $(LIBOBJS) : $(HDRS)

sudo.cat: sudo.man

install: install-binaries install-sudoers install-man

install-binaries: $(PROGS)
	cp sudo $(sudodir)/sudo
	strip $(sudodir)/sudo
	/usr/sbin/chown $(owner) $(sudodir)/sudo
	/bin/chgrp $(group) $(sudodir)/sudo
	chmod 4755 $(sudodir)/sudo
	@if [ -f visudo ]; then \
	    cp visudo $(visudodir)/visudo; \
	    strip $(visudodir)/visudo; \
	    /usr/sbin/chown $(owner) $(visudodir)/visudo; \
	    /bin/chgrp $(group) $(visudodir)/visudo; \
	    chmod 0111 $(visudodir)/visudo; \
	fi

install-sudoers:
	-@test -f $(sudoersdir)/sudoers && echo "Will not overwrite existing $(sudoersdir)/sudoers file." || \
	    (cp sudoers $(sudoersdir)/sudoers && \
	    /usr/sbin/chown $(owner) $(sudoersdir)/sudoers && \
	    /bin/chgrp $(group) $(sudoersdir)/sudoers && \
	    /bin/chmod 0400 $(sudoersdir)/sudoers)

install-man:
	-@if [ -f $(manpage) ]; then \
	    test -d $(mandir) || mkdir -p $(mandir); \
	    cp $(manpage) $(mandir)/sudo.0; \
	    /usr/sbin/chown $(owner) $(mandir)/sudo.0; \
	    /bin/chgrp $(group) $(mandir)/sudo.0; \
	    chmod 0644 $(mandir)/sudo.0; \
	else \
	    echo "Man page $(manpage) not found, skipping."; \
	fi

tags: $(SRCS)
	ctags $(SRCS)

TAGS: $(SRCS)
	etags $(SRCS)

clean:
	-rm -f lex.yy.* y.tab.* *.o $(PROGS) core

mostlyclean: clean

distclean: clean
	rm -f Makefile config.h pathnames.h config.status

realclean: distclean
	rm -f TAGS tags

dist: $(DISTFILES)
	rm -f ../cu-sudo.v1.3.1.tar.Z
	( cd .. ; TF="/tmp/sudo.dist$$" ; rm -f $$TF ; for i in $(DISTFILES) ; \
	  do echo sudo.v1.3.1/$$i >> $$TF ; done ; tar cf cu-sudo.v1.3.1.tar \
	  `cat $$TF` && compress cu-sudo.v1.3.1.tar )
	ls -l ../cu-sudo.v1.3.1.tar.Z
