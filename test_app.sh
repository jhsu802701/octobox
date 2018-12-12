#!/bin/bash

echo '--------------'
echo 'bundle install'
bundle install

echo '----------------'
echo 'rails db:migrate'
rails db:migrate

echo '---------------------------------------------------------------------------------------------'
echo 'DISABLE_SPRING=1 RAILS_ENV=test bundle exec rake --trace rubocop db:migrate test:skip_visuals'
DISABLE_SPRING=1 RAILS_ENV=test bundle exec rake --trace rubocop db:migrate test:skip_visuals

rm dump.rdb
