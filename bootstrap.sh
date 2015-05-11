# The ouput of all these installation steps is noisy. With this utility
# the progress report is nice and concise.
function install {
    echo installing $1
    shift
    apt-get -y install "$@" >/dev/null 2>&1
}

echo updating package information
apt-get -y update >/dev/null 2>&1

install 'development tools' build-essential curl

install Git git

echo installing RVM
sudo -u vagrant -H bash -l -c 'gpg --keyserver hkp://keys.gnupg.net \
  --recv-keys D39DC0E3 && curl --silent -L https://get.rvm.io | bash -s stable'

source /home/vagrant/.rvm/scripts/rvm

echo installing Ruby 2.2.1
sudo -u vagrant -H bash -l -c '/home/vagrant/.rvm/bin/rvm install ruby-2.2.1 \
  --quiet-curl --autolibs=enabled && rvm alias create default 2.2.1'

echo installing Bundler
sudo -u vagrant -H bash -l -c 'gem install bundler -N'

# Postgres pre-installation preparation
update-locale LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8
sudo sh -c "echo 'deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main' > /etc/apt/sources.list.d/pgdg.list"
wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update

install PostgreSQL postgresql-9.3 postgresql-contrib-9.3 libpq-dev
cat << EOF | sudo -u postgres psql
-- Create the database user:
CREATE USER vagrant WITH PASSWORD 'ohanatest';
alter role vagrant superuser;
EOF

install 'Nokogiri dependencies' libxml2 libxml2-dev libxslt1-dev
install 'ExecJS runtime' nodejs

install 'PhantomJS dependencies' bzip2 libfontconfig1
curl --silent -L https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-1.9.8-linux-i686.tar.bz2 \
  --output /opt/phantomjs.tar.bz2 \
  && mkdir /opt/phantomjs \
  && tar --extract --file=/opt/phantomjs.tar.bz2 --strip-components=1 \
  --directory=/opt/phantomjs
sudo ln -s /opt/phantomjs/bin/phantomjs /usr/local/bin/phantomjs

echo 'All done, carry on!'
