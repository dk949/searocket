DESTDIR           ?=
PREFIX            ?= /usr
ZSH_FILE_LOCATION ?= $(PREFIX)/share/searocket
# This is retrieved from git describe automatically if unset
VERSION           ?=
# Only needed for static linking on ldc
LIBDIR            ?=$$(dirname $$(dirname $$(which $(DC))))/lib/

INSTALL_DIR          = $(DESTDIR)$(PREFIX)/bin
ZSH_FILE_INSTALL_DIR = $(DESTDIR)$(ZSH_FILE_LOCATION)

DC ?= ldc2
CC ?= gcc
MODE ?=

DCFLAGS  = -O -release
LDCFLAGS =

OPTIONS = nogc

UTILS = dir      \
        exitcode \
        jobs     \
        took     \
        user

INTEGRATIONS = bun    \
               d      \
               direnv \
               elixir \
               elm    \
               git    \
               go     \
               nix    \
               nodejs \
               python \
               zig
