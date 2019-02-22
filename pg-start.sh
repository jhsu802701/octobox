#!/bin/bash

# NOTE: In the Docker environment, PostgreSQL does NOT automatically start.
# As a result, this script is necessary.

echo '-----------------------------'
echo 'sudo service postgresql start'
sudo service postgresql start

# This app also requires MySQL
echo '------------------------'
echo 'sudo service mysql start'
sudo service mysql start
