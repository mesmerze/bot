#!/bin/bash

set -o errexit
set -o nounset

bundle check || bundle install

bundle exec rails s -b 0.0.0.0
