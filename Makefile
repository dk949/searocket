include config.mk

all: searocket

DFLAGS = -b release
INSTALL_DIR = $(DESTDIR)$(PREFIX)/bin
ZSH_FILE_INSTALL_DIR = $(DESTDIR)$(ZSH_FILE_LOCATION)

searocket: Makefile $(wildcard source/**/*.d)
	dub build $(DFLAGS)

install: searocket
	@echo "installing executable in $(INSTALL_DIR)"
	@echo "installing zsh script in $(ZSH_FILE_INSTALL_DIR)"
	mkdir -p $(INSTALL_DIR)
	mkdir -p $(ZSH_FILE_INSTALL_DIR)
	install searocket $(INSTALL_DIR)/searocket
	install zsh/searocket.zsh $(ZSH_FILE_INSTALL_DIR)/searocket.zsh

uninstall:
	@echo "uninstalling executable from $(INSTALL_DIR)"
	@echo "uninstalling zsh script from $(ZSH_FILE_INSTALL_DIR)"
	rm -f $(INSTALL_DIR)/searocket
	rm -f $(ZSH_FILE_INSTALL_DIR)/searocket.zsh


clean:
	rm -f searocket

.PHONY: clean all
