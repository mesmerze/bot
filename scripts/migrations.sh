#!/bin/bash

set -o errexit
set -o nounset

bundle check || bundle install

if [ ${RAILS_ENV:-"development"} != "production" ]; then
    echo "Creating dbs..."
    bundle exec rake db:create
    echo "OK!"
fi

echo "Running migrations..."
bundle exec rake db:migrate
echo "OK!"

echo "Setting up ffcrm..."
PROCEED=true bundle exec rake ffcrm:setup
echo "OK!"
