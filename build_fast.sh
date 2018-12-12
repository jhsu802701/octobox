#!/bin/bash

sh config_env.sh

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

bash install_geckodriver.sh

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
