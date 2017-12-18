#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

export RAILS_ENV="test"

bundle install --deployment

bundle exec rake spec:preparedb
bundle exec rake spec:models
bundle exec rake spec:mailers
bundle exec rake spec:controllers
bundle exec rake spec:helpers
bundle exec rake spec:lib
bundle exec rake spec:mailers
bundle exec rake spec:routing
bundle exec rake spec:views
bundle exec rake spec:features
bundle exec rubocop
