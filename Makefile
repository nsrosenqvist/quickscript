.POSIX:
SHELL=/bin/bash

NAME=quickscript
VERSION=0.0.1
BUILD_DIR=build
INSTALL_DIR=/usr/local/lib/
TESTS_DIR=tests
PKG_NAME=$(NAME)-$(VERSION).sh
LINK_NAME=$(NAME).sh

all:: build

docs:
	shocker -fTG -o docs/api lib
	echo "$$(cat WIKI.md)" > .docindex.tmp
	tail -n +4 docs/Home.md >> .docindex.tmp
	mv .docindex.tmp docs/Home.md

build:
	mkdir -p "$(BUILD_DIR)/dist"
	mkdir -p "$(BUILD_DIR)/debug"
	./build.sh --VERSION=$(VERSION)

clean:
	rm -f "$(BUILD_DIR)/debug/"*
	rm -f "$(BUILD_DIR)/dist/"*

test:
	./test.sh

tag:
	git tag v$(VERSION)
	git push --tags

release: build docs
	cp "$(BUILD_DIR)/debug/$(PKG_NAME)" "$(BUILD_DIR)/dist/$(PKG_NAME)"

install:
	@echo "Installing $(NAME) $(VERSION)..."
	@echo

	mkdir -p "$(INSTALL_DIR)"

	if [ ! -f "$(BUILD_DIR)/dist/$(PKG_NAME)" ]; then cp "$(BUILD_DIR)/debug/$(PKG_NAME)" "$(BUILD_DIR)/dist/$(PKG_NAME)"; fi

	cp "$(BUILD_DIR)/dist/$(PKG_NAME)" "$(INSTALL_DIR)/$(PKG_NAME)"

	if [ -h "$(INSTALL_DIR)/$(LINK_NAME)" ]; then rm -f "$(INSTALL_DIR)/$(LINK_NAME)"; fi

	ln -s "$(INSTALL_DIR)/$(PKG_NAME)" "$(INSTALL_DIR)/$(LINK_NAME)"
	chmod 0755 "$(INSTALL_DIR)/$(LINK_NAME)"
	chmod 0755 "$(INSTALL_DIR)/$(PKG_NAME)"

	@echo
	@echo "$(NAME) $(VERSION) successfully installed to $(INSTALL_DIR)"
	@echo "Start using $(NAME) by sourcing it into your BASH-scripts: source \"$(INSTALL_DIR)$(LINK_NAME)\""

uninstall:
	rm -f "$(INSTALL_DIR)/$(PKG_NAME)"

	if [ -h "$(INSTALL_DIR)/$(LINK_NAME)" ]; then rm -f "$(INSTALL_DIR)/$(LINK_NAME)"; fi

.PHONY: build clean test tag release install uninstall all docs
