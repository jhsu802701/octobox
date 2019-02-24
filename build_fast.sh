#!/bin/bash

echo 'Welcome to the unofficial build script of the Octobox site!'
echo 'This script assumes that you are using the Ruby on Racetracks'
echo 'protocols to work on this project.'
echo ''
echo 'The purpose of this script is to allow you to quickly and efficiently'
echo 'set up this project.  Setting up the project so that all tests pass'
echo 'will be something you can do in minutes instead of hours.'
echo ''
echo 'Before you continue, please do the following:'
echo '1. Start a second tab in LXTerminal.  Enter the command "sh join.sh".'
echo '   After you enter the Docker container, enter the command'
echo '   "cd octobox; redis-server".'
echo '2. Start a third tab in LXTerminal.  Enter the command "sh join.sh".'
echo '   After you enter the Docker container, enter the command'
echo '   "cd octobox".  Use this tab for entering commands.'
echo '--------------------------------------------------------------'
echo 'When you have satisfied the above requirements, press ENTER to' 
echo 'continue.'
echo 'Otherwise, press Ctrl-C to exit.'
echo '--------------------------------'
read cont

if [ ! -f .env ]; then
  sh config_env.sh
fi

PG_VERSION="$(ls /etc/postgresql)"
PG_HBA="/etc/postgresql/$PG_VERSION/main/pg_hba.conf"
echo '-------------------'
echo "Configuring $PG_HBA"

sudo bash -c "echo '# TYPE  DATABASE        USER            ADDRESS                 METHOD' > $PG_HBA"
sudo bash -c "echo '' >> $PG_HBA"
sudo bash -c "echo '# Allow postgres user to connect to database without password' >> $PG_HBA"
sudo bash -c "echo 'local   all             postgres                                trust' >> $PG_HBA"
sudo bash -c "echo '' >> $PG_HBA"
sudo bash -c "echo 'local   all             all                                     trust' >> $PG_HBA"
sudo bash -c "echo '' >> $PG_HBA"
sudo bash -c "echo '# Full access to 0.0.0.0 (localhost) for pgAdmin host machine access' >> $PG_HBA"
sudo bash -c "echo '# IPv4 local connections:' >> $PG_HBA"
sudo bash -c "echo 'host    all             all             0.0.0.0/0               trust' >> $PG_HBA"
sudo bash -c "echo '' >> $PG_HBA"
sudo bash -c "echo '# IPv6 local connections:' >> $PG_HBA"
sudo bash -c "echo 'host    all             all             ::1/128                 trust' >> $PG_HBA"

sh pg-start.sh
echo '--------------'
echo 'bundle install'
bundle install

bash install_geckodriver.sh # For visual tests

# MySQL
sudo mysql -u root -e 'create database octobox_development;'
sudo mysql -u root -e 'create database octobox_test;'

# PostgreSQL
echo '----------------------------------------'
echo "sudo -u postgres createuser -d $USERNAME"
sudo -u postgres createuser -d $USERNAME

echo '-----------------------------------'
echo "Make the user $USERNAME a superuser"
psql -c "ALTER USER $USERNAME WITH SUPERUSER;" -U postgres

echo '----------------------------------------------------------'
echo "psql -c 'create database octobox_development;' -U postgres"
psql -c 'create database octobox_development;' -U postgres

echo '---------------------------------------------------'
echo "psql -c 'create database octobox_test;' -U postgres"
psql -c 'create database octobox_test;' -U postgres

sh kill_spring.sh
sh all.sh
