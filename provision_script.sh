DBPASSWD=password
echo "Starting..."
echo "updating apt-get"
sudo apt-get update > /dev/null 2>&1

# echo "Installing essentials"
sudo apt-get install -y curl git build-essential python-software-properties nodejs ruby-dev 1> /dev/null

# configure mysql-server with root account if you need it
echo -e "\n--- Install MySQL specific packages and settings ---\n"
echo "mysql-server mysql-server/root_password password $DBPASSWD" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $DBPASSWD" | debconf-set-selections
apt-get -y install mysql-server-5.5

#############
# RVM/ruby setup
#############
echo "Installing rvm"
curl -sSL https://get.rvm.io | bash
source /usr/local/rvm/scripts/rvm
rvm requirements
rvm install 2.2.0
rvm use 2.2.0 --default
echo "gem: --no-ri --no-rdoc" > ~/.gemrc
sudo chown -R vagrant /usr/local/rvm/
gem install bundler
gem install redis
gem install rails -v 4.2.1

#############
# redis setup
#############
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

# nice to have stuff
sudo -u vagrant echo 'set -o vi' >> /home/vagrant/.profile
sudo -u vagrant echo 'cd /vagrant' >> /home/vagrant/.profile
