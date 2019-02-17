#!/bin/bash

echo '--------------'
echo 'bundle install'
bundle install

echo '----------------'
echo 'rails db:migrate'
rails db:migrate

echo '----------------------------------------'
echo 'bundle exec rake db:reset RAILS_ENV=test'
bundle exec rake db:reset RAILS_ENV=test

echo '----------------------------------------------------------------------------'
echo 'RAILS_ENV=test bundle exec rake --trace rubocop db:migrate test:skip_visuals'
RAILS_ENV=test bundle exec rake --trace rubocop db:migrate test:skip_visuals

rm dump.rdb
