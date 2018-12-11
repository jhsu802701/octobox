#!/bin/bash

echo '--------------'
echo 'bundle install'
bundle install

echo '----------------'
echo 'rails db:migrate'
rails db:migrate

# NOTE: The Spring server may distort the test coverage results from MiniTest and SimpleCov.
echo '---------------------------'
echo 'DISABLE_SPRING=1 rails test'
DISABLE_SPRING=1 rails test

