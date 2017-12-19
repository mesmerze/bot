#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

ARTIFACT_BUILD_PATH="/code/dist"
ARTIFACT_NAME="crm.tar.gz"

echo "Preparing build directory..."
rm -rf $ARTIFACT_BUILD_PATH
cp -R /code /tmp/build
rm -rf /tmp/build/vendor/bundle
cp -R /bundle /tmp/build/vendor/bundle
pushd /tmp/build

echo "Installing dependencies..."
bundle install --without development test --deployment
bundle package --all

echo "Pre-compiling assets..."
bundle exec rake assets:precompile

echo "Archiving..."
mkdir -p $ARTIFACT_BUILD_PATH
tar czf "$ARTIFACT_BUILD_PATH/$ARTIFACT_NAME" . --exclude=dist --exclude=.git
chown ${HOST_USER_ID}:${HOST_USER_GID} "$ARTIFACT_BUILD_PATH/$ARTIFACT_NAME"

echo "Cleaning up..."
popd >/dev/null
rm -rf /tmp/build

echo "OK!"
