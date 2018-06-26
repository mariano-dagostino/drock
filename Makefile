# This file help you to use Laradock (https://github.com/laradock/laradock)
# to setup a drupal project fast.

# Run make help for instructions.

# Check the last version in: https://github.com/mariano-dagostino/drock

laradock_version = 6.0.1

# If you plan to build Laradock with diferent configurations you can
# define the name of each setup by changing the following variable:
container_name = drock

containers = mariadb nginx

# Section 1 --------------------------------------------------------------------
# Virtualhosts created by nginx. (machine_name,url,path)

virtualhosts:
	$(call nginx_hosts,drupal.test, \/var\/www\/drupal\/web)
	$(call nginx_hosts,drupal2.test,\/var\/www\/other_drupal\/web)





# Section 2 --------------------------------------------------------------------
# Add here all the commands you want to run in the workspace container before
# complete the build.




define extra_steps_as_root
#!/bin/bash

# Install mysql-client to use drush and drupal-console inside the workspace.
apt-get update
apt-get install -y mysql-client

# Install extra dependencies
#apt-get install -y ruby-dev
#gem install compass

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
endef

define extra_steps_as_laradock
#!/bin/bash

## Install node packages
. ~/.nvm/nvm.sh && \
nvm use stable  && \
npm install -g grunt

## Install ruby
# cd $$HOME
# git clone https://github.com/rbenv/rbenv.git ~/.rbenv
# echo 'export PATH="$$HOME/.rbenv/bin:$$PATH"' >> ~/.bashrc
# echo 'eval "$$(rbenv init -)"' >> ~/.bashrc
#
# git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
# echo 'export PATH="$$HOME/.rbenv/plugins/ruby-build/bin:$$PATH"' >> ~/.bashrc
# eval "$$(~/.rbenv/bin/rbenv init -)"
#
# ~/.rbenv/bin/rbenv install 2.4.3
# ~/.rbenv/bin/rbenv global 2.4.3
# ruby -v
#
# gem install bundler
# gem install compass
# gem install jekyll
# gem install kramdown
endef


# Section 3 --------------------------------------------------------------------
# Define which directories should be created to store cached files.

cache-dirs:
	@mkdir -p cache/.composer
	@mkdir -p cache/.drush
	@mkdir -p cache/.npm
	@mkdir -p cache/.node-gyp
	@mkdir -p cache/.local
	@mkdir -p cache/.cache



# Section 4 --------------------------------------------------------------------
# Define which modules should be enabled or disabled.

env-settings:
	@cp $(container_name)/env-example $(container_name)/.env
	$(call env_enable,PHP_FPM_INSTALL_OPCACHE)
	$(call env_enable,WORKSPACE_INSTALL_NODE)
	$(call env_enable,WORKSPACE_INSTALL_DRUSH)
	$(call env_enable,INSTALL_WORKSPACE_SSH)
	$(call env_disable,WORKSPACE_INSTALL_PYTHON)


# ------------ You don't need to change anything else from here ----------------





export extra_steps_as_root
export extra_steps_as_laradock

all: help

define nginx_hosts
	@cp $(container_name)/nginx/sites/laravel.conf.example       $(container_name)/nginx/sites/$(1).conf
	@sed -i -e 's/root \/var\/www\/laravel\/public;/root $(2);/g' $(container_name)/nginx/sites/$(1).conf
	@sed -i -e 's/server_name laravel.test;/server_name $(1);/g'  $(container_name)/nginx/sites/$(1).conf
	@sed -i -e 's/laravel/$(1)/g' $(container_name)/nginx/sites/$(1).conf
endef

define env_enable
	@sed -i -e 's/$(1)=false/$(1)=true/g' $(container_name)/.env
endef

define env_disable
	@sed -i -e 's/$(1)=true/$(1)=false/g' $(container_name)/.env
endef

extra-steps:
	@# Run the extra steps before the clean up.
	@echo "$$extra_steps_as_root"     > $(container_name)/workspace/extra-root-steps.sh
	@echo "$$extra_steps_as_laradock" > $(container_name)/workspace/extra-user-steps.sh

sed_extra_1 = USER root\nCOPY ./extra-root-steps.sh /tmp\nCOPY ./extra-user-steps.sh /tmp\n
sed_extra_2 = RUN chmod u+x /tmp/extra-*-steps.sh && chown laradock /tmp/extra-user-steps.sh\n
sed_extra_3 = USER root\nRUN /tmp/extra-root-steps.sh\nUSER laradock\nRUN /tmp/extra-user-steps.sh\nUSER root\n\n

env-file: env-settings
	@sed -i -e '/# Clean up/ i$(sed_extra_1)$(sed_extra_2)$(sed_extra_3)' $(container_name)/workspace/Dockerfile-72
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

setup: $(container_name)/docker-compose.yml
	@echo "Laradock installed"

start: env-file virtualhosts extra-steps cache-dirs
	cd $(container_name) && docker-compose up -d $(containers)

reload: stop start

mysql:
	cd $(container_name) && docker-compose exec mariadb bash -c "mysql -u root -proot"

stop:
	cd $(container_name) && docker-compose down

clean:
	rm -fR $(container_name) v$(laradock_version).zip

destroy:
	docker rmi $(container_name)_workspace

bash:
	cd $(container_name) && docker-compose exec --user=laradock workspace bash

bash-root:
	cd $(container_name) && docker-compose exec workspace bash

bash-nginx:
	cd $(container_name) && docker-compose exec nginx bash

bash-php:
	cd $(container_name) && docker-compose exec php-fpm bash

bash-mysql:
	cd $(container_name) && docker-compose exec mariadb bash

help:
	@printf "\n\n\
	Welcome to drock.\n\nTo get started you need to edit the \033[00;41;37mvirtualhosts:\033[0m section\n\
	with your settings in the Makefile file.\n\n\
	Then type \033[00;44;37mmake setup\033[0m to install laradock.\n\n\
	And finally make sure docker is running and type \033[00;42;30mmake start\033[0m to build the containers.\n\n\
	Available commands:\n\
	make setup       Install Laradock $(laradock_version).\n\
	make start       Starts the mariadb, nginx, php and workspace containers.\n\
	make reload      Stop and start again the containers.\n\
	make stop        Stops the containers.\n\
	make clean       Removes Laradock.\n\
	make mysql       Logins you as root inside mysql console.\n\
	make destroy     Destroys the workspace container. Required to apply changes defined in extra steps.\n\
	make bash        Starts a bash session inside the workspace container.\n\
	make bash-root   Starts a bash session as root inside the workspace container.\n\
	make bash-php    Starts a bash session inside the php-fpm container.\n\
	make bash-nginx  Starts a bash session inside the nginx-fpm container.\n\
	make bash-mysql  Starts a bash session inside the mariadb container.\n\
	\n"

# In case you have issues with shared directories, you may want add fix-users
# as dependecy of setup.  (setup: fix-users)
UID := $(shell id -u)
GID := $(shell id -g)
fix-users:
	sed -i -e 's/WORKSPACE_PUID=1000/WORKSPACE_PUID=$(UID)/g' $(container_name)/.env
	sed -i -e 's/WORKSPACE_PGID=1000/WORKSPACE_PGID=$(GID)/g' $(container_name)/.env
