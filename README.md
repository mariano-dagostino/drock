# Drock

[![Build Status](https://travis-ci.org/mariano-dagostino/drock.svg?branch=master)](https://travis-ci.org/mariano-dagostino/drock)

## What is Drock?

Drock is a Makefile that helps you to install, configure and start
[Laradock.io](https://github.com/laradock/laradock) customized to run
[Drupal](https://drupal.org) projects.

This Makefile allows developers to create development environments ready to
use by running a few commands from the terminal.

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

- docker 17+ and docker-compose
- make
- linux
- **Be able to run docker without sudo** [see how](https://docs.docker.com/engine/installation/linux/linux-postinstall/)

## See it in action:

[![asciicast](https://asciinema.org/a/3tn1LeRxKMuViYCy9dubuui7F.png)](https://asciinema.org/a/3tn1LeRxKMuViYCy9dubuui7F)

### Try ContentaCMS with Drock

This example shows how easy is to install [ContentaCMS](http://www.contentacms.org/) using Drock with 4 lines of code.

```
make start
make bash
composer create-project contentacms/contenta-jsonapi-project drupal --stability dev --no-interaction
../bin/drush si contenta_jsonapi --db-url=mysql://root:root@mariadb/dbname -y
```

Don't forget to add `127.0.0.1 drupal.dev` to your /etc/hosts file.

[![asciicast](https://asciinema.org/a/oVN2iPf1ZSsob7NI95Uuz6MAx.png)](https://asciinema.org/a/oVN2iPf1ZSsob7NI95Uuz6MAx)

## Author:

Mariano D'Agostino [drupal.org/u/dagmar](https://www.drupal.org/user/154086)
