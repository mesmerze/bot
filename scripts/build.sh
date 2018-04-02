#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

ARTIFACT_BUILD_PATH="/dist"
ARTIFACT_NAME="crm.tar.gz"

echo "Installing ruby dependencies..."
bundle check || bundle install

echo "Installing JS dependencies..."
cp package.json yarn.lock /deps/
pushd /deps >/dev/null
yarn install --production --frozen-lockfile
rm -f package.json yarn.lock
popd >/dev/null

echo "Preparing build directory..."
if [ ! -d $ARTIFACT_BUILD_PATH ]; then mkdir -p $ARTIFACT_BUILD_PATH; fi
if [ -d $ARTIFACT_BUILD_PATH/$ARTIFACT_NAME ]; then rm -rf $ARTIFACT_BUILD_PATH/$ARTIFACT_NAME; fi

cp -R /code /tmp/build

if [ -d /tmp/build/vendor/bundle ]; then rm -rf /tmp/build/vendor/bundle; fi
if [ -d /tmp/build/vendor/cache ]; then rm -rf /tmp/build/vendor/cache; fi
if [ -d /tmp/build/node_modules ]; then rm -rf /tmp/build/node_modules; fi

cp -R $BUNDLE_PATH /tmp/build/vendor/bundle
cp -R /deps/node_modules/ /tmp/build/node_modules
pushd /tmp/build >/dev/null

echo "Pre-compiling assets..."
bundle exec rake assets:precompile

echo "Archiving..."
tar czf "$ARTIFACT_BUILD_PATH/$ARTIFACT_NAME" . --exclude=dist --exclude=.git --exclude=node_modules
chown ${HOST_USER_ID}:${HOST_USER_GID} "$ARTIFACT_BUILD_PATH/$ARTIFACT_NAME"

echo "Cleaning up..."
popd >/dev/null
rm -rf /tmp/build

echo "OK!"
