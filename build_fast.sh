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

# PostgreSQL
DB_NAME='octobox_test'
DB_USERNAME='winner1'
DB_PASSWORD='long_way_stinks'
echo "OCTOBOX_DATABASE_NAME=${DB_NAME}" >> .env
echo "OCTOBOX_DATABASE_USERNAME=${DB_USERNAME}" >> .env
echo "OCTOBOX_DATABASE_PASSWORD=${DB_PASSWORD}" >> .env

sh pg-start.sh
echo '--------------'
echo 'bundle install'
bundle install

bash install_geckodriver.sh # For visual tests

echo '------------------------------'
echo 'BEGIN: setting up the database'
echo '------------------------------'

psql_command="CREATE ROLE ${DB_USERNAME} WITH CREATEDB LOGIN PASSWORD '${DB_PASSWORD}';"
sudo -u postgres psql -c"$psql_command"
wait

psql_command="ALTER USER ${DB_USERNAME} WITH SUPERUSER;"
sudo -u postgres psql -c"$psql_command"
wait

psql_command="CREATE DATABASE ${DB_NAME} WITH OWNER=${DB_USERNAME};"
sudo -u postgres psql -c"$psql_command"
wait

echo '----------------------------'
echo 'END: setting up the database'
echo '----------------------------'

sh kill_spring.sh
sh all.sh
