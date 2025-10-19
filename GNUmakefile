## Build variables
# Build file locations
build_dir := build/
dist_dir := dist/

# Install locations
prefix := /usr/
bin_prefix = $(prefix)/bin/
man_prefix = $(prefix)/share/man/
fish_prefix = $(prefix)/share/fish/vendor_completions.d/
zsh_prefix = $(prefix)/share/zsh/site-functions/

# Build dependency locations
shellspec_bin := shellspec

# Man page compression method
man_compress_cmd := gzip -9nf
man_compress_ext := .gz


## Target-specific overrides
%/deb: zsh_prefix = $(prefix)/share/zsh/vendor-completions/
%/freebsd: prefix = /usr/local/
%/generic: prefix = $(build_dir)/generic/mommy-$(version)/usr/
%/gentoo: man_compress_cmd := :  # Disables compression by calling the noop `:` command instead
%/gentoo: man_compress_ext :=  # The empty string
%/netbsd: prefix = $(build_dir)/netbsd/usr/pkg/
%/netbsd: man_prefix = $(prefix)/man/
%/openbsd: prefix = $(build_dir)/openbsd/usr/local/
%/openbsd: man_prefix = $(prefix)/man/
%/osxpkg: prefix = /usr/local/


## Extracted values
version := $(shell head -n 1 version)
date := $(shell tail -n 1 version)

comment := $(shell grep -- "--description" .fpm | tr -d "\"" | cut -d " " -f 2-)
maintainer := $(shell grep -- "--maintainer" .fpm | tr -d "\"" | cut -d " " -f 2-)


## Meta
# Output list of targets
.PHONY: list
list:
	@# Taken from https://stackoverflow.com/a/26339924/
	@LC_ALL=C $(MAKE) -pRrq -f "$(lastword $(MAKEFILE_LIST))" : 2>/dev/null | \
		awk -v RS= -F: '/(^|\n)# Files(\n|$$)/,/(^|\n)# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | \
		sort | \
		egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

# Clean up previous builds
.PHONY: clean
clean:
	@rm -rf "$(build_dir)" "$(dist_dir)"


## Tests
.PHONY: test
test: test/unit test/integration

.PHONY: test/%
test/%:
	@MOMMY_MAKE="$(MAKE)" "$(shellspec_bin)" "src/test/sh/$(@:test/%=%)_spec.sh"


## Build
# "Compile" source files into '$(build_dir)' along a simple prefix-based directory layout
.PHONY: build
build:
	@# Copy relevant files
	@mkdir -p "$(build_dir)/bin/"
	@cp src/main/sh/mommy "$(build_dir)/bin/"

	@mkdir -p "$(build_dir)/man/man1/"
	@cp src/main/man/man1/mommy.1 "$(build_dir)/man/man1/"

	@mkdir -p "$(build_dir)/completions/fish/"
	@cp src/main/completions/fish/mommy.fish "$(build_dir)/completions/fish/"

	@mkdir -p "$(build_dir)/completions/zsh/"
	@cp src/main/completions/zsh/_mommy "$(build_dir)/completions/zsh/"

	@# Insert version information
	@sed -i".bak" \
		"s/%%VERSION_NUMBER%%/$(version)/g;s/%%VERSION_DATE%%/$(date)/g" \
		"$(build_dir)/bin/mommy" \
		"$(build_dir)/man/man1/mommy.1"
	@rm -f "$(build_dir)/bin/mommy.bak" "$(build_dir)/man/man1/mommy.1.bak"

	@# Compress
	@$(man_compress_cmd) "$(build_dir)/man/man1/mommy.1"

# Build, with target-specific overrides from the preamble
.PHONY: build/%
build/%: build ;


## Installation
# Copy built files into prefix-appropriate directories
.PHONY: install
install: build
	@# Create directories
	@install -m 755 -d "$(bin_prefix)" "$(man_prefix)/man1/" "$(fish_prefix)" "$(zsh_prefix)"

	@# Copy files
	@install -m 755 "$(build_dir)/bin/mommy" "$(bin_prefix)"
	@install -m 644 "$(build_dir)/man/man1/mommy.1$(man_compress_ext)" "$(man_prefix)/man1/"
	@install -m 644 "$(build_dir)/completions/fish/mommy.fish" "$(fish_prefix)"
	@install -m 644 "$(build_dir)/completions/zsh/_mommy" "$(zsh_prefix)"

# Install, with target-specific overrides from the preamble
.PHONY: install/%
install/%: install ;


## Uninstallation
# Remove installed files
.PHONY: uninstall
uninstall:
	@rm "$(bin_prefix)/mommy"
	@rm "$(man_prefix)/man1/mommy.1$(man_compress_ext)"
	@rm "$(fish_prefix)/mommy.fish"
	@rm "$(zsh_prefix)/_mommy"

# Uninstall, with target-specific overrides from the preamble
.PHONY: uninstall/%
uninstall/%: uninstall ;


## Build distributable packages
.PHONY: dist/%

# Build generic extractable package
dist/generic: install
	@mkdir -p "$(dist_dir)"
	@tar -C "$(build_dir)/generic/" -czf "$(dist_dir)/mommy-$(version)+generic.tar.gz" ./

# Build packages with fpm
dist/apk: fpm/apk
dist/deb: fpm/deb
dist/freebsd: fpm/freebsd
dist/osxpkg: fpm/osxpkg
	@# 'installer' program requires 'pkg' extension
	@mv "$(dist_dir)/"*".osxpkg" "$(dist_dir)/mommy-$(version)+osx.pkg"
dist/pacman: fpm/pacman
dist/rpm: fpm/rpm

# Build NetBSD package manually
dist/netbsd: install
	@cd "$(build_dir)/netbsd"; find . -type f | sed -e "s/^/.\//" > +CONTENTS

	@echo "$(comment)" > "$(build_dir)/netbsd/+COMMENT"

	@echo "$(comment)" 				   > "$(build_dir)/netbsd/+DESC"
	@echo "" 						  >> "$(build_dir)/netbsd/+DESC"
	@echo "Maintainer: $(maintainer)" >> "$(build_dir)/netbsd/+DESC"

	@echo "MACHINE_ARCH=$$(uname -p)"           > "$(build_dir)/netbsd/+BUILD_INFO"
	@echo "OPSYS=$$(uname)"                    >> "$(build_dir)/netbsd/+BUILD_INFO"
	@echo "OS_VERSION=$$(uname -r)"            >> "$(build_dir)/netbsd/+BUILD_INFO"
	@echo "PKGTOOLS_VERSION=$$(pkg_create -V)" >> "$(build_dir)/netbsd/+BUILD_INFO"


	@cd "$(build_dir)/netbsd"; \
	pkg_create \
		-B +BUILD_INFO \
		-c +COMMENT \
		-d +DESC \
		-f +CONTENTS \
		-I / \
		-p . \
		"mommy-$(version)+netbsd.tgz"

	@mkdir -p "$(dist_dir)"
	@mv "$(build_dir)/netbsd/mommy-$(version)+netbsd.tgz" "$(dist_dir)"

# Build OpenBSD package manually
dist/openbsd: install
	@cd "$(build_dir)/openbsd"; find . -type f | sed -e "s/^/.\//" > +CONTENTS

	@echo "$(comment)" > "$(build_dir)/openbsd/+COMMENT"

	@echo "$(comment)" > "$(build_dir)/openbsd/+DESC"


	@cd "$(build_dir)/openbsd"; \
	pkg_create \
		-d +DESC \
		-D COMMENT="$(comment)" \
		-D FULLPKGPATH="mommy-$(version)+netbsd" \
		-D MAINTAINER="$(maintainer)" \
		-f +CONTENTS \
		-B "$$(pwd)/" \
		-p / \
		"mommy-$(version)+openbsd.tgz"

	@mkdir -p "$(dist_dir)"
	@mv "$(build_dir)/openbsd/mommy-$(version)+openbsd.tgz" "$(dist_dir)"

# Invoke 'fpm/<target>' on built files to create an output of type '<target>'
# For valid '<target>'s, see https://fpm.readthedocs.io/en/latest/packaging-types.html
.PHONY: fpm/%
fpm/%: build
	@mkdir -p "$(dist_dir)"
	@fpm -t "$(@:fpm/%=%)" \
		-p "$(dist_dir)/mommy-$(version).$(@:fpm/%=%)" \
		--version "$(version)" \
		--freebsd-osversion "*" \
		\
		"$(build_dir)/bin/mommy=$(bin_prefix)/mommy" \
		"$(build_dir)/man/man1/mommy.1$(man_compress_ext)=$(man_prefix)/man1/mommy.1$(man_compress_ext)" \
		"$(build_dir)/completions/fish/mommy.fish=$(fish_prefix)/mommy.fish" \
		"$(build_dir)/completions/zsh/_mommy=$(zsh_prefix)/_mommy"
