#!/bin/bash

echo '-----------------------------'
echo 'BEGIN: installing geckodriver'
echo '-----------------------------'

GECKO_VERSION='v0.22.0'
ARCH=`arch`
BIT_STR='64'
if [[ "$ARCH" == 'i686' ]]
then
  BIT_STR='32'
fi
GECKO_URL="https://github.com/mozilla/geckodriver/releases/download/${GECKO_VERSION}/geckodriver-${GECKO_VERSION}-linux${BIT_STR}.tar.gz"
GECKO_FILENAME="geckodriver-${GECKO_VERSION}-linux${BIT_STR}.tar.gz"

wget $GECKO_URL
wait
tar -xzf $GECKO_FILENAME -C bin
wait
sudo mv bin/geckodriver /usr/local/bin

rm $PWD/$GECKO_FILENAME
export PATH=$(pwd)/bin:$PATH

echo '--------------------------------'
echo 'FINISHED: installing geckodriver'
echo '--------------------------------'
