.PHONY: dev shell build publish test stop destroy

dev:
	docker-compose up --build web

shell:
	docker-compose run web /bin/bash

build:
	HOST_USER_ID=$(shell id -u) HOST_USER_GID=$(shell id -g) docker-compose up --build artifact

publish:
	./scripts/publish.sh

test:
	docker-compose up --build test

stop:
	docker-compose stop

destroy:
	docker-compose down

.PHONY: migrations sample-data update-gemfile

# Runs DB migrations
migrations:
	docker-compose run web ./scripts/migrations.sh

# Loads sample data for the CRM
sample-data:
	docker-compose run web bundle exec rake ffcrm:demo:load

# Updates Gemfile.lock
update-gemfile:
	docker-compose run web bundle install --no-deployment
