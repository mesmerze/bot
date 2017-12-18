.PHONY: dev shell build publish test stop destroy

dev:
	docker-compose up --build web

shell:
	docker-compose run web /bin/bash

build:
	docker-compose build artifact
	HOST_USER_ID=$(id -u) HOST_USER_GID=$(id -g) docker-compose run artifact
	docker-compose stop artifact

publish: build
	./scripts/publish.sh

test:
	docker-compose build test
	docker-compose run test
	docker-compose stop test

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

update-gemfile:
	docker-compose run web bundle install --no-deployment
