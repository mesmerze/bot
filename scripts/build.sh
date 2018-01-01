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
rm -rf /tmp/build/vendor/cache
cp -R /bundle /tmp/build/vendor/bundle
pushd /tmp/build >/dev/null

echo "Checking for missing dependencies..."
export BUNDLE_IGNORE_CONFIG="1"
export BUNDLE_PATH="/tmp/build/vendor/bundle/ruby/2.3.0"
export BUNDLE_WITHOUT="development:test"
bundle check || bundle install --without development test --deployment --path "/bundle" && rm -rf ./vendor/bundle && cp -R /bundle /tmp/build/vendor/bundle

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
