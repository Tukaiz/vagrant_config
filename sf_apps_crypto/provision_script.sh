echo "updating apt-get"
sudo apt-get update 1> /dev/null

#############
# Basics setup
#############
echo "Installing essentials"
sudo apt-get install -y curl git build-essential ruby-dev 1> /dev/null

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
sudo -u vagrant cd /vagrant & bundle install

#############
# nice to have stuff
#############
sudo -u vagrant echo 'set -o vi' >> /home/vagrant/.profile
sudo -u vagrant echo 'cd /vagrant' >> /home/vagrant/.profile
