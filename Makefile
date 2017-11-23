# This file help you to use Laradock (https://github.com/laradock/laradock) 
# to setup a drupal project fast.

# Run make help for instructions.

# Check the last version in: https://github.com/mariano-dagostino/drock

laradock_version = 5.8.3

UID := $(shell id -u)
GID := $(shell id -g)

all: help

laradock/nginx/sites/drupal.conf:
	@cp laradock/nginx/sites/laravel.conf.example laradock/nginx/sites/drupal.conf
	@sed -i -e 's/root \/var\/www\/laravel\/public;/root \/var\/www\/drupal\/web;/g' laradock/nginx/sites/drupal.conf
	@sed -i -e 's/server_name laravel.dev;/server_name drupal.dev;/g' laradock/nginx/sites/drupal.conf
	@sed -i -e 's/laravel/drupal/g' laradock/nginx/sites/drupal.conf
	@echo "Add 127.0.0.1 drupal.dev to your /etc/hosts file"

laradock/.env:
	@cp laradock/env-example laradock/.env
	@sed -i -e 's/PHP_FPM_INSTALL_OPCACHE=false/PHP_FPM_INSTALL_OPCACHE=true/g' laradock/.env
	@sed -i -e 's/WORKSPACE_PUID=1000/WORKSPACE_PUID=$(UID)/g' laradock/.env
	@sed -i -e 's/WORKSPACE_PGID=1000/WORKSPACE_PGID=$(GID)/g' laradock/.env
	
	@# Workarround to install mysql-client to make drush & console work.
	@sed -i -e 's/^RUN apt-get clean \&\&/RUN apt-get install mysql-client -y \&\& apt-get clean \&\&/g' laradock/workspace/Dockerfile-71
	@sed -i -e 's/^RUN apt-get clean \&\&/RUN apt-get install mysql-client -y \&\& apt-get clean \&\&/g' laradock/workspace/Dockerfile-70
	@sed -i -e 's/^RUN apt-get clean \&\&/RUN apt-get install mysql-client -y \&\& apt-get clean \&\&/g' laradock/workspace/Dockerfile-56

	@# Make sure opcache.use_cwd is enabled. If not, is not possible to install multiple drupal sites in the same container.
	@sed -i -e 's/opcache.use_cwd="0"/opcache.use_cwd="1"/g' laradock/php-fpm/opcache.ini

	@echo "Laradock .env file created."

laradock/docker-compose.yml:
	@curl -sLO https://github.com/laradock/laradock/archive/v$(laradock_version).zip
	@unzip -q v$(laradock_version).zip
	@mv laradock-$(laradock_version) laradock
	@rm -f v$(laradock_version).zip
	@echo "Laradock $(laradock_version) downloaded"

setup: laradock/docker-compose.yml laradock/.env laradock/nginx/sites/drupal.conf
	@echo "Laradock installed"

start: setup
	cd laradock && docker-compose up -d nginx mariadb

bash: 
	cd laradock && docker-compose exec --user=laradock workspace bash

bash-nginx: 
	cd laradock && docker-compose exec nginx bash

bash-php: 
	cd laradock && docker-compose exec php-fpm bash

mysql: 
	cd laradock && docker-compose exec workspace "mysql -h -u root -proot mariadb"

stop:
	cd laradock && docker-compose down

clean:
	rm -fR laradock v$(laradock_version).zip

help:
	@echo "make setup   Install Laradock $(laradock_version)."
	@echo "make start   Starts the mariadb, nginx, php and workspace containers."
	@echo "make clean   Removes Laradock."
