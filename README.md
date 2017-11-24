# Drock

[![Build Status](https://travis-ci.org/mariano-dagostino/drock.svg?branch=master)](https://travis-ci.org/mariano-dagostino/drock)

## What is Drock?

Drock is a Makefile that helps you to install, configure and start
[Laradock.io](https://github.com/laradock/laradock) customized to run
[Drupal](https://drupal.org) projects.

## How to use it?

Assuming you already have [docker](https://www.docker.com) installed, copy the
**[Makefile](https://raw.githubusercontent.com/mariano-dagostino/drock/master/Makefile)** into a folder:

```
mkdir your_project && cd your_project
curl -LO https://raw.githubusercontent.com/mariano-dagostino/drock/master/Makefile
```

Then run:

`make setup`

This will download Laradock and configure drupal.dev as virtualhost.

And finally just run:

`make start`

The containers will be launched and your development environment will be ready.

## What is next?

- Don't forget to configure your `/etc/hosts` file. Add `127.0.0.1 drupal.dev`
- You can login to the workspace container by running `make bash`
- Drupal is not installed by default, the expected path for the index.php file is `/var/www/drupal/web/index.php`

## List of commmands:

- `make setup` Installs laradock.
- `make start` Starts the container.
- `make bash`  Logs you into the workspace container using bash. [bash-php, bash-nginx are also avaible.)
- `make stop`  Stops the containers.
- `make clean` Deletes laradock files.

## Requirements:

- docker 17+
- make
- linux

## Author:

Mariano D'Agostino [drupal.org/u/dagmar](https://www.drupal.org/user/154086)
