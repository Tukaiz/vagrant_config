#!/bin/bash

# use these flags to install the services you need.
INSTALL_POSTGRES=
INSTALL_MYSQL=true
INSTALL_DOCKER=
INSTALL_REDIS=
INSTALL_RUBY=true

# specify your versions and db configs below
# we have to do some major hackings because 1.8.6 causes compatibility issues wit
RUBY_VERSION=1.8.7
RUBY_GEMS_VERSION=1.3.5
PG_VERSION=9.4
APP_DB_USER=vagrant
APP_DB_PASSWORD=password

##############
# Script start
##############

# upgrade system
apt-get update && sudo apt-get -y upgrade

# install git
sudo apt-get -y install git git-core
# install developer packages and other paraphernalia (geez)
apt-get -y install            \
  make                        \
  build-essential             \
  libssl-dev                  \
  libreadline6-dev            \
  zlib1g-dev                  \
  libyaml-dev                 \
  libc6-dev                   \
  libpq-dev                   \
  libcurl4-openssl-dev        \
  libksba8                    \
  libksba-dev                 \
  libqtwebkit-dev             \
  autoconf                    \
  bison                       \
  libncurses5-dev             \
  libffi-dev                  \
  libgdbm3                    \
  libgdbm-dev                 \
  nodejs                      \
  python-software-properties  \

# nokogiri requirements
apt-get -y install libxslt-dev libxml2-dev
# headless requirements
apt-get -y install xvfb
# capybara-webkit requirements
apt-get -y install libqt4-dev

####################
# Install ruby build
####################
if [ $INSTALL_RUBY ]; then
  curl -sSL https://get.rvm.io | bash
  source /usr/local/rvm/scripts/rvm
  rvm requirements
  rvm install $RUBY_VERSION
  rvm use $RUBY_VERSION --default
  echo "gem: --no-ri --no-rdoc" > ~/.gemrc
  sudo chown -R vagrant /usr/local/rvm/
  if [ $INSTALL_RUBY ]; then
    rvm install rubygems $RUBY_GEMS_VERSION --force
  fi
fi

#############
# Install mysql
#############
if [ $INSTALL_MYSQL ]; then
  # configure mysql-server with root account if you need it
  echo "mysql-server mysql-server/root_password password $APP_DB_PASSWORD" | debconf-set-selections
  echo "mysql-server mysql-server/root_password_again password $APP_DB_PASSWORD" | debconf-set-selections
  sudo apt-get -y install mysql-server-5.5 libmysqlclient-dev
fi

#############
# Install postgres (shamelessly stolen from https://github.com/jackdb/pg-app-dev-vm)
#############
if [ $INSTALL_POSTGRES ]; then
  echo "--- Install Postgres ---"
  PG_REPO_APT_SOURCE=/etc/apt/sources.list.d/pgdg.list
  if [ ! -f "$PG_REPO_APT_SOURCE" ]
  then
    # Add PG apt repo:
    echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > "$PG_REPO_APT_SOURCE"
    # Add PGDG repo key:
    wget --quiet -O - https://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | apt-key add -
  fi

  apt-get update 1> /dev/null
  apt-get -y upgrade 1> /dev/null
  apt-get -y install "postgresql-$PG_VERSION" "postgresql-contrib-$PG_VERSION" 1> /dev/null

  PG_CONF="/etc/postgresql/$PG_VERSION/main/postgresql.conf"
  PG_HBA="/etc/postgresql/$PG_VERSION/main/pg_hba.conf"
  PG_DIR="/var/lib/postgresql/$PG_VERSION/main"

  # Edit postgresql.conf to change listen address to '*':
  sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" "$PG_CONF"
  # Append to pg_hba.conf to add password auth:
  echo "host    all             all             all                     md5" >> "$PG_HBA"
  # Explicitly set default client_encoding
  echo "client_encoding = utf8" >> "$PG_CONF"
  # Restart so that all new config is loaded:
  service postgresql restart
  # add roles for development and what not
  echo "CREATE ROLE $APP_DB_USER WITH LOGIN PASSWORD '$APP_DB_PASSWORD';" | sudo -u postgres psql postgres
  echo "ALTER ROLE $APP_DB_USER WITH SUPERUSER;" | sudo -u postgres psql postgres
fi

#############
# Install docker
#############
if [ $INSTALL_DOCKER ]; then
  echo "--- Install Docker ---"
  wget -qO- https://get.docker.com/ | sh > /dev/null 2>&1
fi

#############
# redis setup
#############
if [ $INSTALL_REDIS ]; then
  echo "Installing redis"
  # (no apt-get as this tends to be out of date.. use port 6379)
  cd ~/
  wget http://download.redis.io/redis-stable.tar.gz > /dev/null 2>&1
  tar xzvf redis-stable.tar.gz > /dev/null 2>&1

  cd redis-stable
  make > /dev/null 2>&1

  sudo cp src/redis-server /usr/local/bin/
  sudo cp src/redis-cli /usr/local/bin/

  sudo mkdir /etc/redis
  sudo mkdir /var/redis
  sudo mkdir /var/redis/6379

  sudo cp /vagrant/redis.init.d /etc/init.d/redis_6379
  sudo cp /vagrant/redis.conf /etc/redis/6379.conf

  sudo update-rc.d redis_6379 defaults

  sudo chmod -R 777 /var/redis
  sudo chmod 755 /etc/init.d/redis_6379

  cd ~/
  rm -rf redis-stable
  rm redis-stable.tar.gz

  # kick off redis
  /etc/init.d/redis_6379 start
fi

#############
# Nice to have things
#############
sudo -u vagrant echo 'set -o vi' >> /home/vagrant/.profile
sudo -u vagrant echo 'cd /vagrant' >> /home/vagrant/.profile
cd /home/vagrant/
