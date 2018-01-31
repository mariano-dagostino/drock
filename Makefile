# This file help you to use Laradock (https://github.com/laradock/laradock)
# to setup a drupal project fast.

# Run make help for instructions.

# Check the last version in: https://github.com/mariano-dagostino/drock

laradock_version = 5.9.0

# If you plan to build Laradock with diferent configurations you can
# define the name of each setup by changing the following variable:
container_name = drock

# Add here all the commands you want to run in the
# workspace container before complete the build.
define extra_steps
#!/bin/bash

# Install mysql-client to use drush and drupal-console inside the workspace.
apt-get update
apt-get install -y mysql-client
endef

export extra_steps

UID := $(shell id -u)
GID := $(shell id -g)

all: help

$(container_name)/nginx/sites/drupal.conf:
	@cp $(container_name)/nginx/sites/laravel.conf.example $(container_name)/nginx/sites/drupal.conf
	@sed -i -e 's/root \/var\/www\/laravel\/public;/root \/var\/www\/drupal\/web;/g' $(container_name)/nginx/sites/drupal.conf
	@sed -i -e 's/server_name laravel.test;/server_name drupal.test;/g' $(container_name)/nginx/sites/drupal.conf
	@sed -i -e 's/laravel/drupal/g' $(container_name)/nginx/sites/drupal.conf
	@echo "Add 127.0.0.1 drupal.test to your /etc/hosts file"

$(container_name)/.env:
	@cp $(container_name)/env-example $(container_name)/.env
	@sed -i -e 's/PHP_FPM_INSTALL_OPCACHE=false/PHP_FPM_INSTALL_OPCACHE=true/g' $(container_name)/.env
	@# In case you have issues with shared directories, you may want to uncomment
	@# this lines.
	@#sed -i -e 's/WORKSPACE_PUID=1000/WORKSPACE_PUID=$(UID)/g' $(container_name)/.env
	@#sed -i -e 's/WORKSPACE_PGID=1000/WORKSPACE_PGID=$(GID)/g' $(container_name)/.env

	@# Run the extra steps before the clean up.
	@echo "$$extra_steps" > $(container_name)/workspace/extra-steps.sh
	@sed -i -e '/# Clean up/ iCOPY ./extra-steps.sh /tmp\nRUN chmod u+x /tmp/extra-steps.sh && /tmp/extra-steps.sh\n' $(container_name)/workspace/Dockerfile-71
	@sed -i -e '/# Clean up/ iCOPY ./extra-steps.sh /tmp\nRUN chmod u+x /tmp/extra-steps.sh && /tmp/extra-steps.sh\n' $(container_name)/workspace/Dockerfile-70
	@sed -i -e '/# Clean up/ iCOPY ./extra-steps.sh /tmp\nRUN chmod u+x /tmp/extra-steps.sh && /tmp/extra-steps.sh\n' $(container_name)/workspace/Dockerfile-56

	@# Make sure opcache.use_cwd is enabled. If not, is not possible to install multiple drupal sites in the same container.
	@sed -i -e 's/opcache.use_cwd="0"/opcache.use_cwd="1"/g' $(container_name)/php-fpm/opcache.ini

	@echo "Laradock .env file created."

$(container_name)/docker-compose.yml:
	@curl -sLO https://github.com/laradock/laradock/archive/v$(laradock_version).zip
	@unzip -q v$(laradock_version).zip
	@mv laradock-$(laradock_version) $(container_name)
	@rm -f v$(laradock_version).zip
	@echo "Laradock $(laradock_version) downloaded"

setup: $(container_name)/docker-compose.yml $(container_name)/.env $(container_name)/nginx/sites/drupal.conf
	@echo "Laradock installed"

start: setup
	cd $(container_name) && docker-compose up -d nginx mariadb

bash:
	cd $(container_name) && docker-compose exec --user=laradock workspace bash

bash-nginx:
	cd $(container_name) && docker-compose exec nginx bash

bash-php:
	cd $(container_name) && docker-compose exec php-fpm bash

bash-mysql:
	cd $(container_name) && docker-compose exec mariadb bash

mysql:
	cd $(container_name) && docker-compose exec mariadb bash -c "mysql -u root -proot"

stop:
	cd $(container_name) && docker-compose down

clean:
	rm -fR $(container_name) v$(laradock_version).zip

help:
	@echo "make setup       Install Laradock $(laradock_version)."
	@echo "make start       Starts the mariadb, nginx, php and workspace containers."
	@echo "make clean       Removes Laradock."
	@echo "make bash        Starts a bash session inside the workspace container."
	@echo "make mysql       Logins you as root inside mysql console."
	@echo "make bash-php    Starts a bash session inside the php-fpm container."
	@echo "make bash-nginx  Starts a bash session inside the nginx-fpm container."
	@echo "make bash-mysql  Starts a bash session inside the mariadb container."
