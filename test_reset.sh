#!/bin/bash

# This script resets the test database.

echo '----------------------------------------'
echo 'bundle exec rake db:reset RAILS_ENV=test'
bundle exec rake db:reset RAILS_ENV=test
