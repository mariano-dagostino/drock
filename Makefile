# This file help you to use Laradock (https://github.com/laradock/laradock)
# to setup a drupal project fast.

# Run make help for instructions.

# Check the last version in: https://github.com/mariano-dagostino/drock

laradock_version = 5.9.0

# If you plan to build Laradock with diferent configurations you can
# define the name of each setup by changing the following variable:
container_name = drock

containers = mariadb nginx

drupal_url   = drupal.test
drupal_path  = \/var\/www\/drupal\/web
drupal_theme = \/var\/www\/drupal\/web\/themes\/custom\/custom_theme
compile_theme_cmd = compass compile

# Add here all the commands you want to run in the
# workspace container before complete the build.
define extra_steps_as_root
#!/bin/bash

# Install mysql-client to use drush and drupal-console inside the workspace.
apt-get update
apt-get install -y mysql-client

# Install extra dependencies
apt-get install -y ruby-dev
gem install compass

# If you want to keep the cache for downloaded packages across container reloads.
cd /home/laradock
rm -fR .drush     \
       .composer  \
       .local     \
       .cache

ln -s /var/www/cache/.drush       /home/laradock/.drush
ln -s /var/www/cache/.composer    /home/laradock/.composer
ln -s /var/www/cache/.local       /home/laradock/.local
ln -s /var/www/cache/.cache       /home/laradock/.cache

# Allow to login via ssh using laradock user.
usermod -p "*" laradock
endef

define extra_steps_as_laradock
#!/bin/bash

. ~/.nvm/nvm.sh && \
nvm use stable && \
npm install -g debug
endef

export extra_steps_as_root
export extra_steps_as_laradock

all: help

cache-dirs:
	@mkdir -p cache/.composer
	@mkdir -p cache/.drush
	@mkdir -p cache/.local
	@mkdir -p cache/.cache

nginx-conf:
	@cp $(container_name)/nginx/sites/laravel.conf.example                  $(container_name)/nginx/sites/$(drupal_url).conf
	@sed -i -e 's/root \/var\/www\/laravel\/public;/root $(drupal_path);/g' $(container_name)/nginx/sites/$(drupal_url).conf
	@sed -i -e 's/server_name laravel.test;/server_name $(drupal_url);/g'   $(container_name)/nginx/sites/$(drupal_url).conf
	@sed -i -e 's/laravel/$(drupal_url)/g'                                  $(container_name)/nginx/sites/$(drupal_url).conf

extra-steps:
	@# Run the extra steps before the clean up.
	@echo "$$extra_steps_as_root"     > $(container_name)/workspace/extra-root-steps.sh
	@echo "$$extra_steps_as_laradock" > $(container_name)/workspace/extra-user-steps.sh

sed_extra_1 = USER root\nCOPY ./extra-root-steps.sh /tmp\nCOPY ./extra-user-steps.sh /tmp\n
sed_extra_2 = RUN chmod u+x /tmp/extra-*-steps.sh && chown laradock /tmp/extra-user-steps.sh\n
sed_extra_3 = USER root\nRUN /tmp/extra-root-steps.sh\nUSER laradock\nRUN /tmp/extra-user-steps.sh\nUSER root\n\n
$(container_name)/.env:
	@cp $(container_name)/env-example $(container_name)/.env
	@sed -i -e 's/PHP_FPM_INSTALL_OPCACHE=false/PHP_FPM_INSTALL_OPCACHE=true/g'   $(container_name)/.env
	@sed -i -e 's/WORKSPACE_INSTALL_NODE=false/WORKSPACE_INSTALL_NODE=true/g'     $(container_name)/.env
	@sed -i -e 's/WORKSPACE_INSTALL_DRUSH=false/WORKSPACE_INSTALL_DRUSH=true/g'   $(container_name)/.env
	@sed -i -e 's/WORKSPACE_INSTALL_PYTHON=false/WORKSPACE_INSTALL_PYTHON=true/g' $(container_name)/.env
	@sed -i -e 's/INSTALL_WORKSPACE_SSH=false/INSTALL_WORKSPACE_SSH=true/g'       $(container_name)/.env

	@sed -i -e '/# Clean up/ i$(sed_extra_1)$(sed_extra_2)$(sed_extra_3)' $(container_name)/workspace/Dockerfile-71
	@sed -i -e '/# Clean up/ i$(sed_extra_1)$(sed_extra_2)$(sed_extra_3)' $(container_name)/workspace/Dockerfile-70
	@sed -i -e '/# Clean up/ i$(sed_extra_1)$(sed_extra_2)$(sed_extra_3)' $(container_name)/workspace/Dockerfile-56

	@# Make sure opcache.use_cwd is enabled. If not, is not possible to install multiple drupal sites in the same container.
	@sed -i -e 's/opcache.use_cwd="0"/opcache.use_cwd="1"/g' $(container_name)/php-fpm/opcache.ini
	@echo "Laradock .env file created."

$(container_name)/docker-compose.yml:
	@echo "Downloading Laradock..."
	@curl -sLO https://github.com/laradock/laradock/archive/v$(laradock_version).zip
	@unzip -q v$(laradock_version).zip
	@mv laradock-$(laradock_version) $(container_name)
	@rm -f v$(laradock_version).zip
	@echo "Laradock $(laradock_version) downloaded"

setup: $(container_name)/docker-compose.yml $(container_name)/.env
	@echo "Laradock installed"

start: nginx-conf extra-steps cache-dirs
	cd $(container_name) && docker-compose up -d $(containers)

reload: stop start

bash:
	cd $(container_name) && docker-compose exec --user=laradock workspace bash

theme:
	@cd $(container_name) && docker-compose exec --user=laradock workspace bash -c "cd $(drupal_theme) && $(compile_theme_cmd) && drush cc all" && notify-send "Theme compiled"

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
	@echo "make reload      Stop and start again the containers."
	@echo "make stop        Stops the containers"
	@echo "make clean       Removes Laradock."
	@echo "make bash        Starts a bash session inside the workspace container."
	@echo "make mysql       Logins you as root inside mysql console."
	@echo "make bash-php    Starts a bash session inside the php-fpm container."
	@echo "make bash-nginx  Starts a bash session inside the nginx-fpm container."
	@echo "make bash-mysql  Starts a bash session inside the mariadb container."

# In case you have issues with shared directories, you may want add fix-users
# as dependecy of setup.  (setup: fix-users)
UID := $(shell id -u)
GID := $(shell id -g)
fix-users:
	sed -i -e 's/WORKSPACE_PUID=1000/WORKSPACE_PUID=$(UID)/g' $(container_name)/.env
	sed -i -e 's/WORKSPACE_PGID=1000/WORKSPACE_PGID=$(GID)/g' $(container_name)/.env
