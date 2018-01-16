#!/bin/bash

set -o errexit
set -o nounset

bundle check || bundle install

bundle exec rake db:create
bundle exec rake spec:preparedb
bundle exec rake spec:models
bundle exec rake spec:mailers
bundle exec rake spec:controllers
bundle exec rake spec:helpers
bundle exec rake spec:lib
bundle exec rake spec:mailers
bundle exec rake spec:routing
bundle exec rake spec:views
# bundle exec rake spec:features
bundle exec rubocop
