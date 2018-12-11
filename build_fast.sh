#!/bin/bash

sh config_env.sh

echo '-------------------'
echo 'sudo apt-get update'
sudo apt-get update

# Needed for MySQL
echo '--------------------------------------------------'
echo 'sudo apt-get install -y default-libmysqlclient-dev'
sudo apt-get install -y default-libmysqlclient-dev

sh pg-start.sh

sh kill_spring.sh
sh all.sh
