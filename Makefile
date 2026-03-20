SRC = lus.lua
PREFIX ?= /usr/local
INSTALL_DIR = $(PREFIX)/bin
INSTALL_TARGET = $(INSTALL_DIR)/lus

SKILL_DIR = skill/
CODEX_DIR = $(HOME)/.codex/

FISH_COMPLETION_DIR = $(HOME)/.config/fish/completions/

install:
	cp $(SRC) "$(DESTDIR)$(INSTALL_TARGET)"
	chmod +x "$(DESTDIR)$(INSTALL_TARGET)"

install-skill:
	@if [ -d "$(CODEX_DIR)" ]; then \
		echo "Codex config directory found, installing lus skill..."; \
		cp -r $(SKILL_DIR) "$(CODEX_DIR)skills/lus"; \
	fi

install-completion:
	install -m 644 completions.fish "$(FISH_COMPLETION_DIR)lus.fish"

.PHONY: install install-skill install-completion
