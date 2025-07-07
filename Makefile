SRC = lus.lua
INSTALL_DIR = /usr/local/bin/
INSTALL_TARGET = $(INSTALL_DIR)$(notdir lus)

install:
	cp $(SRC) $(INSTALL_TARGET)
	chmod +x $(INSTALL_TARGET)
	install -m 644 completions.fish /usr/share/fish/completions/lus.fish

.PHONY: install
