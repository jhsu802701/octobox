#!/bin/bash

# Run this script before entering "git add" and "git commit".

sh test_app.sh

echo '---------------------------------------'
echo 'bundle exec brakeman -Aq -w2 --no-pager'
bundle exec brakeman -Aq -w2 --no-pager

echo '----------------------'
echo 'bundle exec rubocop -D'
bundle exec rubocop -D

echo '----------'
echo 'git status'
git status
