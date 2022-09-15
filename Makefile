PREFIX ?= $(HOME)/.local
ZSH_FILE_LOCATION ?= $(PREFIX)/share/searocket

all: searocket

searocket: Makefile $(wildcard source/*.d)
	dub build -b release

install: searocket
	@echo "installing executable in $(PREFIX)/bin"
	@echo "installing zsh script in $(ZSH_FILE_LOCATION)"
	mkdir -p $(PREFIX)/bin
	mkdir -p $(ZSH_FILE_LOCATION)
	install searocket $(PREFIX)/bin/searocket
	install zsh/searocket.zsh $(ZSH_FILE_LOCATION)/searocket.zsh

uninstall:
	@echo "uninstalling executable from $(PREFIX)/bin"
	@echo "uninstalling zsh script from $(ZSH_FILE_LOCATION)"
	rm -f $(PREFIX)/bin/searocket
	rm -f $(ZSH_FILE_LOCATION)/searocket.zsh
