#!/bin/bash

echo 'Welcome to the unofficial build script of the Octobox site!'
echo 'This script assumes that you are using the Ruby on Racetracks'
echo 'system to work on this project and that you are using the'
echo 'pre-installed tmux tool to provide simultaneous multiple windows'
echo 'to interact with the same Docker container.'
echo ''
echo 'The purpose of this script is to allow you to quickly and efficiently'
echo 'set up this project.  Setting up the project so that all tests pass'
echo 'will be something you can do in minutes instead of hours.'
echo ''
echo 'Before you continue, please do the following:'
echo '1. If you are not in a tmux window, stop this script, run tmux,'
echo '   and run this script again.'
echo '2. Start a second tmux window, and start the Redis server.  Enter'
echo '   the command "cd octobox; redis-server".'
echo '3. Start a third tmux window for entering additional commands.'
echo '--------------------------------------------------------------'
echo 'When you have satisfied the above requirements, press ENTER to' 
echo 'continue.'
echo 'Otherwise, press Ctrl-C to exit.'
echo '--------------------------------'
read cont

echo ''
echo '***************************************************'
echo 'IMPORTANT: This app needs GitHub App credentials to'
echo 'work in the development environment.'
echo
echo '--------------------------------------------------'
echo 'Follow these steps to get your GitHub credentials:'
echo '1. Log into your GitHub account.'
echo '2. Go to https://github.com/settings/profile .'
echo '3. Click on "Developer settings".'
echo '4. If you already created an OAuth app, click on it and'
echo '   get your Client ID and Client Secret.'
echo '   Make sure that the port numbers in your home page URL'
echo '   and authorization callback URL are correct for your'
echo '   Docker container.'
echo '   Then skip ahead to enter your credentials.'
echo '5. If you did not already create an OAuth app, click on'
echo '   "Register a New Application".'
echo '6. Use "octobox" as your application name.'
echo '7. Use "http://localhost:3000/" as the Homepage URL.'
echo '   NOTE: If you are using a non-zero offset for the port numbers,'
echo '   the port number will be different from 3000.'
echo '8. Use "http://localhost:3000/users/auth/github/callback" as'
echo '   the Authorization callback URL.'
echo '   NOTE: If you are using a non-zero offset for the port numbers,'
echo '   the port number will be different from 3000.'
echo '9. Click on "Register application".  If all goes well, your'
echo '   Client ID and Client Secret are now provided.'
echo
echo '+++++++++++++++++++++++++++++++'
echo 'Enter the GitHub App Client ID:'
read GITHUB_ID

echo 'Enter the GitHub App Client Secret:'
read GITHUB_SECRET

echo GITHUB_APP_ID=$GITHUB_ID > .env
echo GITHUB_APP_SECRET=$GITHUB_SECRET >> .env
echo PORT=3000 >> .env
