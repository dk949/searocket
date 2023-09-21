DESTDIR           ?=
PREFIX            ?= /usr
ZSH_FILE_LOCATION ?= $(PREFIX)/share/searocket

INSTALL_DIR          = $(DESTDIR)$(PREFIX)/bin
ZSH_FILE_INSTALL_DIR = $(DESTDIR)$(ZSH_FILE_LOCATION)

DC ?= ldc2
CC ?= gcc

DCFLAGS  = -O -release
LDCFLAGS =

UTILS = nogc     \
        user     \
        dir      \
        exitcode \
        took     \
        jobs

INTEGRATIONS = bun    \
               d      \
               elm    \
               git    \
               go     \
               nodejs \
               python \
               zig
