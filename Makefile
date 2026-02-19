SRC = lus.lua
PREFIX ?= /usr/local/
INSTALL_DIR = $(PREFIX)bin/
INSTALL_TARGET = $(INSTALL_DIR)$(notdir lus)

SKILL_DIR = skill/
CODEX_DIR = $(HOME)/.codex/

install:
	cp $(SRC) "$(INSTALL_TARGET)"
	chmod +x "$(INSTALL_TARGET)"
	install -m 644 completions.fish /usr/share/fish/completions/lus.fish

install-skill:
	@if [ -d "$(CODEX_DIR)" ]; then \
		echo "Codex config directory found, installing lus skill..."; \
		cp -r $(SKILL_DIR) "$(CODEX_DIR)skills/lus"; \
	fi

.PHONY: install install-skill
