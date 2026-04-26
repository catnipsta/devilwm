############################################################################
# devilwm - minimalist window manager for X11
# Copyright (C) 1999-2022 Ciaran Anscomb <evilwm@6809.org.uk>
# Copyright (C) 2026 Nikolai Klover <nick8klover@outlook.com>
# see README for license and other details.

# do not include any other makefiles above this line.
THISMAKEFILE=$(lastword $(MAKEFILE_LIST))
# allow trivial out-of-tree builds
src_dir=$(dir $(THISMAKEFILE))
VPATH=$(src_dir)

############################################################################
# Installation paths

prefix = /usr
bindir = $(prefix)/bin
datarootdir = $(prefix)/share
mandir = $(datarootdir)/man
man1dir = $(mandir)/man1
desktopfilesdir = $(datarootdir)/applications

############################################################################
# Features

# Note: some options to reconfigure keyboard mappings have been removed, as the
# "-bind" option should allow that at runtime.

# Uncomment to enable use of sqrt() function in monitor distance calculations.
OPT_CPPFLAGS += -DHAVE_MATH_H
OPT_LDLIBS += -lm

# Uncomment to enable info banner on holding Ctrl+Alt+I.
OPT_CPPFLAGS += -DINFOBANNER

# Uncomment to show the same banner on moves and resizes.  Can be SLOW!
#OPT_CPPFLAGS += -DINFOBANNER_MOVERESIZE

# Uncomment to support the Xrandr extension (thanks, Yura Semashko).
OPT_CPPFLAGS += -DRANDR
OPT_LDLIBS   += -lXrandr

# Uncomment to support shaped windows.
OPT_CPPFLAGS += -DSHAPE
OPT_LDLIBS   += -lXext

# Uncomment to enable solid window drags.  This can be slow on old systems.
OPT_CPPFLAGS += -DSOLIDDRAG

# Uncomment to move pointer around on certain actions.
#OPT_CPPFLAGS += -DWARP_POINTER

# Uncomment to include whatever debugging messages I've left in this release.
#OPT_CPPFLAGS += -DDEBUG   # miscellaneous debugging
#OPT_CPPFLAGS += -DXDEBUG  # show some X calls

OPT_CPPFLAGS += -DNDEBUG  # disable asserts

# Uncomment to map KEY_TOPLEFT to XK_z (suitable for quertz keyboards)
#OPT_CPPFLAGS += -DQWERTZ_KEYMAP

############################################################################
# Include file and library paths

# Most Linux distributions don't separate out X11 from the rest of the
# system, but some other OSs still require extra information:

# Solaris 10:
#OPT_CPPFLAGS += -I/usr/X11/include
#OPT_LDFLAGS += -R/usr/X11/lib -L/usr/X11/lib

# Solaris <= 9 doesn't support RANDR feature above, so disable it there
# Solaris 9 doesn't fully implement ISO C99 libc, to suppress warnings, use:
#OPT_CPPFLAGS += -D__EXTENSIONS__

# OpenBSD 6.2
#OPT_CPPFLAGS += -I/usr/X11R6/include
#OPT_LDFLAGS += -L/usr/X11R6/lib

# Mac OS X:
#OPT_LDFLAGS += -L/usr/X11R6/lib

############################################################################
# Build tools

# Change this if you don't use gcc:
CC = gcc

# Override if desired:
CFLAGS = -Os
WARN = -Wall -W -Wstrict-prototypes -Wpointer-arith -Wcast-align \
	-Wshadow -Waggregate-return -Wnested-externs -Winline -Wwrite-strings \
	-Wundef -Wsign-compare -Wmissing-prototypes -Wredundant-decls

# Enable to spot explicit casts that strip constant qualifiers.
# generally not needed, since an explicit cast should signify
# the programmer guarantees no undefined behaviour.
#WARN += -Wcast-qual

# For Cygwin:
#EXEEXT = .exe

INSTALL = install
STRIP = strip
INSTALL_DIR = $(INSTALL) -d -m 0755
INSTALL_FILE = $(INSTALL) -m 0644
INSTALL_PROGRAM = $(INSTALL) -m 0755

# If you do not use GNU Make, you may need to comment out this line (and the
# output from 'configure' will not be used):
-include config.mk

############################################################################
# You shouldn't need to change anything beyond this point

version = 1.4.3
distdir = devilwm-$(version)

# Generally shouldn't be overridden:
#  _XOPEN_SOURCE=700 incorporates POSIX.1-2008, for putenv, sigaction and strdup
EVILWM_CPPFLAGS = $(CPPFLAGS) $(OPT_CPPFLAGS) -DVERSION=\"$(version)\" \
	-D_XOPEN_SOURCE=700 -DHAVE_CONFIG_H
EVILWM_CFLAGS = -std=c99 $(CFLAGS) $(WARN)
EVILWM_LDFLAGS = $(LDFLAGS)
EVILWM_LDLIBS = -lX11 $(OPT_LDLIBS) $(LDLIBS)

HEADERS = bind.h client.h config.h display.h events.h devilwm.h func.h \
	list.h log.h screen.h util.h xalloc.h xconfig.h
OBJS = bind.o client.o client_move.o client_new.o display.o events.o ewmh.o \
	func.o list.o log.o main.o screen.o util.o xconfig.o xmalloc.o

.PHONY: all
all: devilwm$(EXEEXT)

$(OBJS): $(HEADERS)

%.o: %.c
	$(CC) $(EVILWM_CFLAGS) $(EVILWM_CPPFLAGS) -c $<

devilwm$(EXEEXT): $(OBJS)
	$(CC) -o $@ $(OBJS) $(EVILWM_LDFLAGS) $(EVILWM_LDLIBS)

.PHONY: install
install: devilwm$(EXEEXT)
	$(INSTALL_DIR) $(DESTDIR)$(bindir)
	$(INSTALL_PROGRAM) devilwm$(EXEEXT) $(DESTDIR)$(bindir)/
	$(INSTALL_DIR) $(DESTDIR)$(man1dir)
	$(INSTALL_FILE) $(src_dir)/devilwm.1 $(DESTDIR)$(man1dir)/
	$(INSTALL_DIR) $(DESTDIR)$(desktopfilesdir)
	$(INSTALL_FILE) $(src_dir)/devilwm.desktop $(DESTDIR)$(desktopfilesdir)/

.PHONY: install-strip
install-strip: install
	$(STRIP) $(DESTDIR)$(bindir)/devilwm$(EXEEXT)

.PHONY: uninstall
uninstall:
	rm -f $(DESTDIR)$(bindir)/devilwm$(EXEEXT)
	rm -f $(DESTDIR)$(man1dir)/devilwm.1
	rm -f $(DESTDIR)$(desktopfilesdir)/devilwm.desktop

.PHONY: dist
dist:
	git archive --format=tar --prefix=$(distdir)/ HEAD > $(distdir).tar
	gzip -f9 $(distdir).tar

.PHONY: debuild
debuild: dist
	-cd ..; rm -rf $(distdir)/ $(distdir).orig/
	mv $(distdir).tar.gz ../devilwm_$(version).orig.tar.gz
	cd ..; tar xfz devilwm_$(version).orig.tar.gz
	rsync -axH debian --exclude='debian/.git/' --exclude='debian/_darcs/' ../$(distdir)/
	cd ../$(distdir); debuild

.PHONY: clean
clean:
	rm -f devilwm$(EXEEXT) $(OBJS)

.PHONY: distclean
distclean: clean
	rm -f config.mk
