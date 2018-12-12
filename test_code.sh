#!/bin/bash

# This script runs the app through code metrics.
# Violations will not stop the app from passing but will be flagged here.

echo '----------------------'
echo 'bundle install --quiet'
bundle install --quiet

# Checks for security vulnerabilities
# -A: runs all checks
# -q: output the report only; suppress information warnings
# -w2: level 2 warnings (medium and high only)
echo '---------------------------------------'
echo 'bundle exec brakeman -Aq -w2 --no-pager'
bundle exec brakeman -Aq -w2 --no-pager

# Checks for violations of the Ruby Style Guide, not recommended for legacy apps
echo '----------------------'
echo 'bundle exec rubocop -D'
bundle exec rubocop -D
