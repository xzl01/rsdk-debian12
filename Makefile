PROJECT ?= rsdk-debian12
PREFIX ?= /usr
BINDIR ?= $(PREFIX)/bin
LIBDIR ?= $(PREFIX)/lib
MANDIR ?= $(PREFIX)/share/man

# Docker image packaging settings moved to `debian/rules`
IMAGE_NAME ?= rsdk-debian12
ARCHS ?= amd64 arm64

.PHONY: build-deb-all
build-deb-all: deb


.PHONY: distclean
distclean: clean

.PHONY: clean
clean: clean-deb

.PHONY: clean-deb
clean-deb:
	rm -rf debian/.debhelper debian/${PROJECT} debian/debhelper-build-stamp debian/files debian/*.debhelper.log debian/*.postrm.debhelper debian/*.substvars

.PHONY: dch
dch: debian/changelog
	EDITOR=true gbp dch --debian-branch=main --commit --release --dch-opt=--upstream --multimaint-merge

.PHONY: deb
deb: debian
	debuild --no-lintian --lintian-hook "lintian  --suppress-tags bad-distribution-in-changes-file -- %p_%v_*.changes" --no-sign -b

.PHONY: release
release:
	gh workflow run .github/workflows/new_version.yml
