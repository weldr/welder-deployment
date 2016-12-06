# Composer Deployment

This repository contains configuration files for orchestrating the building and
deployment of the composer tool. Currently this consists of:

 * Building the metadata import tool.
 * Using the tool to import a set of rpms and create a metadata.db
 * Create a storage container for recipes
 * Launch the bdcs-api container, connected to the metadata.db and recipe storage.
 * Launch the composer UI container, with the `API_URL` set to point to the bdcs-api image.

We use docker-composer to manage this.

## Makefile helper

The makefile provides several useful targets and some directory setup to make
this easier. Starting from a new repository clone you can get to a copy of the
composer application running on port 80 by doing the following:

 * `make build` to use github or `make build-local` to use the current branch on local repos.
 * Symlink a repository of rpms to import to `./rpms/` or export `IMPORT_PATH`
 * `make import` will import the rpms into the `metadata.db` file inside the `bdcs-mddb-volume`
 * `make run` will run the api container, attached to the mddb container, and the composer-UI
   container connected to port 80.

### build and build-local

`make build` will checkout the latest version of bdcs, bdcs-api-rs and
composer-UI from github and rebuild the `wiggum/*` images. ssh access to github
must be setup for this to work.

Alternatively, if the projects already exist at ../bdcs, ../bdcs-api-rs,
../composer-UI, you can use `make build-local` and those repos will be cloned
and used for the build. The current branch is used, so this can be useful for
development before pushing to github. Note that these are checkouts so
uncomitted changes won't be used.

### import

`make impor` will import the rpms from ./rpms/ into the metadata.db stored in
the `bdcs-mddb-volume`.  You can point to a different path for the rpms by
setting the `IMPORT_PATH` variable when running `make import` or by symlinking
the path to the rpms to ./rpms/

This step expects ./bdcs/ to have been previously cloned -- it uses the
Makefile from it.

### run

`make run` will launch the `wiggum/bdcs-api` image with the `bdcs-mddb-volume`
attached to it, and the `wiggum/composer-UI` module with the http server
running on port 80.

### clean

`make clean` will remove the checkout directories.

### local-repos

`make local-repos` will make sure that the local repos are used for the images.


## Default docker-compose.yml configuration

This configuration is used for building the bdcs-api and composer-UI images, as
well as for running them. It is setup to attach to port 80 on the host. If
another port needs to be used, edit the file to change it in the `web`
section's `ports` settings.

building the images with this configuration requires some setup, see the
Makefile section for details.

The `bdcs-recipes-volume` is created the first time this is run, and will
persist between uses of docker-compose or docker. At runtime it will copy the
example recipe into it.

