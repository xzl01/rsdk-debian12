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

.PHONY: all
all: deb


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

.PHONY: ensure-buildx
ensure-buildx:
	@if command -v docker >/dev/null 2>&1 && docker buildx version >/dev/null 2>&1; then \
	  echo "docker buildx is available"; \
	else \
	  if command -v apt-get >/dev/null 2>&1; then \
	    (command -v sudo >/dev/null 2>&1 && sudo apt-get update || apt-get update) >/dev/null 2>&1 || true; \
	    (command -v sudo >/dev/null 2>&1 && sudo apt-get install -y --no-install-recommends docker-buildx-plugin docker-buildx || apt-get install -y --no-install-recommends docker-buildx-plugin docker-buildx) >/dev/null 2>&1 || true; \
	  fi; \
	  if command -v docker >/dev/null 2>&1 && docker buildx version >/dev/null 2>&1; then \
	    echo "docker buildx installed via apt"; \
	  elif [ -x scripts/install-buildx.sh ]; then \
	    echo "docker buildx missing; installing via scripts/install-buildx.sh"; \
	    scripts/install-buildx.sh; \
	  else \
	    echo "ERROR: docker buildx not available and scripts/install-buildx.sh not found" 1>&2; exit 1; \
	  fi; \
	fi

.PHONY: test
test: deb
	@pkg=$$(ls -t ../rsdk-debian12_*.deb | head -n1); \
	if [ -z "$$pkg" ]; then \
	  echo "ERROR: no built rsdk-debian12_*.deb found; run make deb first" 1>&2; exit 1; \
	fi; \
	if command -v sudo >/dev/null 2>&1; then SUDO=sudo; else SUDO=; fi; \
	$$SUDO dpkg -i "$$pkg" || { $$SUDO apt-get update && $$SUDO apt-get -f install -y && $$SUDO dpkg -i "$$pkg"; }; \
	command -v run-rsdk-debian12 >/dev/null 2>&1 && echo "Installed and run-rsdk-debian12 is present"

.PHONY: deb
deb: ensure-buildx debian
	debuild --no-lintian --lintian-hook "lintian  --suppress-tags bad-distribution-in-changes-file -- %p_%v_*.changes" --no-sign -b

.PHONY: release
release:
	gh workflow run .github/workflows/new_version.yml
