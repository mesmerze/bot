#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

ARTIFACT_BUILD_PATH="/dist"
ARTIFACT_NAME="crm.tar.gz"

echo "Installing dependencies..."
export BUNDLE_IGNORE_CONFIG="1"
export BUNDLE_GLOBAL_GEM_CACHE="1"
export BUNDLE_FROZEN="1"
export BUNDLE_DEPLOYMENT="1"
export BUNDLE_WITHOUT="development:test"
export BUNDLE_GEMFILE="/code/Gemfile"
bundle check || bundle install

echo "Preparing build directory..."
if [ ! -d $ARTIFACT_BUILD_PATH ]; then mkdir -p $ARTIFACT_BUILD_PATH; fi
if [ ! -d $ARTIFACT_BUILD_PATH/$ARTIFACT_NAME ]; then rm -rf $ARTIFACT_BUILD_PATH/$ARTIFACT_NAME; fi

cp -R /code /tmp/build

if [ ! -d /tmp/build/vendor/bundle ]; then rm -rf /tmp/build/vendor/bundle; fi
if [ ! -d /tmp/build/vendor/cache ]; then rm -rf /tmp/build/vendor/cache; fi

cp -R $BUNDLE_PATH /tmp/build/vendor/bundle
pushd /tmp/build >/dev/null

echo "NPM install..."
npm install

echo "Pre-compiling assets..."
bundle exec rake assets:precompile

echo "Archiving..."
tar czf "$ARTIFACT_BUILD_PATH/$ARTIFACT_NAME" . --exclude=dist --exclude=.git
chown ${HOST_USER_ID}:${HOST_USER_GID} "$ARTIFACT_BUILD_PATH/$ARTIFACT_NAME"

echo "Cleaning up..."
popd >/dev/null
rm -rf /tmp/build

echo "OK!"
