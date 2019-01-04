#!/bin/bash

# NOTE: The bundle install and database migration are skipped here.
# It is assumed that you already completed these steps, which are
# covered in the build_fast.sh script.

# This script tests the workers only.

echo '-----------------------'
echo 'rails test test/workers'
rails test test/workers
