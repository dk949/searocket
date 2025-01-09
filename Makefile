include config.mk

SRC_DIR			= source
GEN_CONF_DIR	= views
VERSIONS        = $($(MODE)OPTIONS) $($(MODE)UTILS) $($(MODE)INTEGRATIONS)

DEBUGDCFLAGS    = -g --gc -d-debug
DEBUGLDCFLAGS   = -g --gc -d-debug
REAL_DCFLAGS    = $($(MODE)DCFLAGS)
REAL_LDCFLAGS   = $($(MODE)LDCFLAGS)

REAL_DCFLAGS    += -m64 -J$(GEN_CONF_DIR) -I$(SRC_DIR) $(VERSIONS:%=-d-version %)
REAL_LDCFLAGS   += -L-ldl -m64

INTEG_FILES = $($(MODE)INTEGRATIONS:%=$(SRC_DIR)/prompt/integrations/%.d) $(SRC_DIR)/prompt/integrations/common.d
INTEG_PKG   = $(SRC_DIR)/prompt/integrations/package.d
SRC         = $(shell find $(SRC_DIR) -maxdepth 2 -name *.d) $(INTEG_FILES) $(INTEG_PKG)
OBJ         = $(SRC:$(SRC_DIR)/%.d=build/%.o)
DEPS        = $(SRC:$(SRC_DIR)/%.d=build/%.dep)

SCRIPTS    = $(wildcard scripts/*.d)
SCRIPT_EXE = $(SCRIPTS:%.d=%)
GEN        = $(GEN_CONF_DIR)/use_icons


DEBUGOPTIONS = nogc \
               timing

DEBUGUTILS = dir      \
             exitcode \
             jobs     \
             took     \
             user

DEBUGINTEGRATIONS = battery \
                    bun     \
                    d       \
                    docker  \
                    elixir  \
                    elm     \
                    git     \
                    go      \
                    haskell \
                    java    \
                    julia   \
                    nix     \
                    nodejs  \
                    php     \
                    python  \
                    ruby    \
                    rust    \
                    swift   \
                    xcode   \
                    zig     \


all: build/searocket build/searocket.zsh

scripts/%: scripts/%.d
	$(DC) $< -of $@

$(INTEG_PKG): scripts/makeintegrations $(INTEG_FILES)
	$< $(SRC_DIR)/prompt/integrations/ $@

build/searocket.zsh: scripts/makezshfile
	$< $@

$(GEN_CONF_DIR)/use_icons: scripts/makeconfig
	$< $(GEN_CONF_DIR)

build/%.o: $(SRC_DIR)/%.d
	@mkdir -p $(dir $@)
	$(DC) --makedeps=$(basename $@).dep $(REAL_DCFLAGS) $< -of $@ -c

$(OBJ): Makefile config.mk $(GEN) $(INTEG_PKG)

build/searocket: $(OBJ)
	$(DC) $(REAL_LDCFLAGS) $^ -of $@
	strip $@

clean:
	rm -rf build/*
	rm -f $(INTEG_PKG)
	rm -f $(SCRIPT_EXE)

install: build/searocket build/searocket.zsh
	@echo "installing executable in $(INSTALL_DIR)"
	@echo "installing zsh script in $(ZSH_FILE_INSTALL_DIR)"
	install -D build/searocket $(INSTALL_DIR)/searocket
	install -D build/searocket.zsh $(ZSH_FILE_INSTALL_DIR)/searocket.zsh

uninstall:
	@echo "uninstalling executable from $(INSTALL_DIR)"
	@echo "uninstalling zsh script from $(ZSH_FILE_INSTALL_DIR)"
	rm -f $(INSTALL_DIR)/searocket
	rm -f $(ZSH_FILE_INSTALL_DIR)/searocket.zsh


-include $(DEPS)
