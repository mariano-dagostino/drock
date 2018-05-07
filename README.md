# Drock

[![Build Status](https://travis-ci.org/mariano-dagostino/drock.svg?branch=master)](https://travis-ci.org/mariano-dagostino/drock)

## What is Drock?

Drock is a Makefile that helps you install, configure and start
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

This will download Laradock and configure drupal.test as virtualhost.

And finally just run:

`make start`

The containers will be launched and your development environment will be ready.

## What is next?

- Don't forget to configure your `/etc/hosts` file. Add `127.0.0.1 drupal.dev`
- You can login to the workspace container by running `make bash`
- Drupal is not installed by default, the expected path for the index.php file is `/var/www/drupal/web/index.php`

## List of commmands:

Run `make help` to see the list of commands.

- `make setup`       Install Laradock.
- `make start`       Starts the mariadb, nginx, php and workspace containers.
- `make reload`      Stop and start again the containers.
- `make stop`        Stops the containers.
- `make clean`       Removes Laradock.
- `make mysql`       Logins you as root inside mysql console.
- `make destroy`     Destroys the workspace container. Required to apply changes defined in extra steps.
- `make bash`        Starts a bash session inside the workspace container.
- `make bash-root`   Starts a bash session as root inside the workspace container.
- `make bash-php`    Starts a bash session inside the php-fpm container.
- `make bash-nginx`  Starts a bash session inside the nginx-fpm container.
- `make bash-mysql`  Starts a bash session inside the mariadb container.


## Requirements:

- `docker 17+` and `docker-compose`
- make
- linux
- **Be able to run docker without sudo** [see how](https://docs.docker.com/engine/installation/linux/linux-postinstall/)

**Note for Mac users**:

Mac OSX has a different version of sed which requires file extensions when using the -i option.

The easiest fix is to install the GNU version of sed using homebrew:

`brew install gnu-sed --with-default-names`

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

### Also works with BLT

If you plan to use [BLT](http://blt.readthedocs.io/en/latest/readme/creating-new-project/) from Acquia to run your site, you can use the following commands:

```
make start
make bash
composer create-project --no-interaction acquia/blt-project drupal
# You will need to logout from the terminal the first time
make bash
cd drupal
blt
```

[![asciicast](https://asciinema.org/a/a3iSaIHBqkLFs4hhOMhe7lrg6.png)](https://asciinema.org/a/a3iSaIHBqkLFs4hhOMhe7lrg6)

## Author:

Mariano D'Agostino [drupal.org/u/dagmar](https://www.drupal.org/user/154086)
