#!/bin/bash

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
echo '8. Use "http://localhost:3000/auth/github/callback" as'
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

echo GITHUB_CLIENT_ID=$GITHUB_ID > .env
echo GITHUB_CLIENT_SECRET=$GITHUB_SECRET >> .env
echo PORT=3000 >> .env
