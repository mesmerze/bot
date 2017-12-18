#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rake ffcrm:setup
