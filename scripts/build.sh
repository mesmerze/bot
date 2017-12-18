#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

export RAILS_ENV=production

rm -rf dist

echo "Installing dependencies..."
bundle install --without development test --deployment
bundle package --all

echo "Pre-compiling assets..."
bundle exec rake assets:precompile

mkdir -p dist

echo "Archiving..."
tar czf "dist/crm.tar.gz" . --exclude=dist --exclude=.git

chown ${HOST_USER_ID}:${HOST_USER_GID} "/code/dist/crm.tar.gz"

echo "Done!"
