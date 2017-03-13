BUILDER_OPTIONS = --force-clean --ccache --require-changes
TARGET_REPO = repo
APP_FOLDER = sublime
REPO_NAME = latest-$(APP_FOLDER)
FLATPAK = $(shell which flatpak)
FLATPAK_BUILDER = $(shell which flatpak-builder)
FLATPAK_APP_NAME = com.sublimetext.three
MANIFEST = $(FLATPAK_APP_NAME).json

all: install-deps build prune install-repo
	$(FLATPAK) --user update $(FLATPAK_APP_NAME)

install-deps:
	$(FLATPAK) --user remote-add --if-not-exists --from gnome-nightly https://sdk.gnome.org/gnome.flatpakrepo
	$(FLATPAK) --user install gnome-nightly org.gnome.Platform/x86_64/master org.gnome.Sdk/x86_64/master || true

build: $(MANIFEST)
				$(FLATPAK_BUILDER) \
								$(BUILDER_OPTIONS) \
								--repo=$(TARGET_REPO) \
								$(APP_FOLDER) \
								$(MANIFEST)

clean:
	rm -rf $(APP_FOLDER) $(TARGET_REPO) .flatpak-builder

prune:
	$(FLATPAK) build-update-repo --prune --prune-depth=20 $(TARGET_REPO)

install-repo:
	$(FLATPAK) --user remote-add --if-not-exists --no-gpg-verify $(REPO_NAME) ./$(TARGET_REPO)
	$(FLATPAK) --user install $(REPO_NAME) $(FLATPAK_APP_NAME) || true
