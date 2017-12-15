# Helpers for building and running the welder docker images
# Set IMPORT_PATH to the path of the rpms to import or bind mount to ./rpms/
IMPORT_PATH ?= $(PWD)

GIT_ORG_URL=https://github.com/weldr
REPOS=bdcs bdcs-api-rs welder-web

default: all

repos: $(REPOS)

weld-fedora: Dockerfile-weld
	sudo docker build -t welder/fedora:26 --cache-from welder/fedora:latest -f Dockerfile-weld .
	sudo docker tag      welder/fedora:26 welder/fedora:latest

# given a repo in REPOS, clone it from GIT_ORG_URL
$(REPOS):%:
	git clone $(GIT_ORG_URL)/$@

# clone from local copies of repos
local-repos: GIT_ORG_URL=..
local-repos: clean repos

# Build the weld/* docker images. No rpms are imported and no images are run.
build: repos weld-fedora
	sudo $(MAKE) -C bdcs importer
	sudo docker-compose build

# This uses local checkouts one directory above
build-local: local-repos build

# Import the RPMS from IMPORT_PATH and create ./mddb/metadata.db and ./mddb/cs.repo
import: repos
	@if [ -h $(IMPORT_PATH)/rpms ]; then \
		echo "ERROR: $(IMPORT_PATH)/rpms/ cannot be a symlink"; \
		exit 1; \
	fi; \
	if [ ! -d $(IMPORT_PATH)/rpms ]; then \
		echo "ERROR: $(IMPORT_PATH)/rpms/ must exist"; \
		exit 1; \
	fi; \
	if [ -h $(IMPORT_PATH)/mddb ]; then \
		echo "ERROR: $(IMPORT_PATH)/mddb/ cannot be a symlink"; \
		exit 1; \
	fi; \
	sudo WORKSPACE=$(IMPORT_PATH) $(MAKE) -C bdcs mddb

run: repos
	sudo docker-compose up

run-background: repos
	sudo docker-compose up -d

all:
	@echo "Try 'make build', 'make import', or 'make run'."
	@echo "(make sure Docker is running first!)"

clean:
	rm -rf $(REPOS)


.PHONY: clean build import run build-local
