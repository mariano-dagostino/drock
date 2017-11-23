# Drock

## What is Drock?

Drock is a Makefile that helps you to install, configure and start
[Laradock.io](https://github.com/laradock/laradock) to run
[Drupal](https://drupal.org) projects.

## How to use it.

Assuming you already have [docker](https://www.docker.com) installed, copy the
Makefile into a folder and then run:

`make setup`

This will download Laradock and configure drupal.dev as virtualhost.

Then just run:

`make start`

And this will build all the containers and start your development environment.

## List of commmands

- `make setup` Installs laradock.
- `make start` Starts the container.
- `make bash`  Logs you into the workspace container using bash. [bash-php, bash-nginx are also avaible.)
- `make stop`  Stops the containers.
- `make clean` Deletes laradock files.

## Requirements

- docker 17+
- make
- linux

## Author

Mariano D'Agostino [drupal.org/u/dagmar](https://www.drupal.org/user/154086)
