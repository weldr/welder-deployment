# Helpers for building and running the composer docker images
# Set IMPORT_PATH to the path of the rpms to import or bind mount to ./rpms/
IMPORT_PATH ?= $(PWD)

default: all

repos: ./bdcs ./bdcs-api-rs ./composer-UI

bdcs:
	git clone git@github.com:wiggum/bdcs.git

bdcs-api-rs:
	git clone git@github.com:wiggum/bdcs-api-rs.git

composer-UI:
	git clone git@github.com:wiggum/composer-UI.git

local-repos:
	rm -rf ./bdcs ./bdcs-api-rs ./composer-UI
	git clone ../bdcs/
	git clone ../bdcs-api-rs
	git clone ../composer-UI

# Build the wiggum/* docker images. No rpms are imported and no images are run.
build: repos
	$(MAKE) -C bdcs importer
	sudo docker-compose build

# This uses local checkouts one directory above
build-local: local-repos
	$(MAKE) -C bdcs importer
	sudo docker-compose build

# Import the RPMS from IMPORT_PATH and create the bdcs-mddb-volume
import: repos
	WORKSPACE=$(IMPORT_PATH) $(MAKE) -C bdcs mddb

run: repos
	sudo docker-compose up

all:
	echo "Choose one of build, import, or run."

clean:
	rm -rf ./bdcs ./bdcs-api-rs ./composer-UI


.PHONY: clean build import run build-local
