default: build
.PHONY: default

dev:
	docker-compose up --build web
.PHONY: dev

build:
	HOST_USER_ID=$(shell id -u) HOST_USER_GID=$(shell id -g) docker-compose up --build --exit-code-from artifact --abort-on-container-exit artifact
.PHONY: build

publish:
	./scripts/publish.sh
.PHONY: publish

test:
	docker-compose up --build --exit-code-from test --abort-on-container-exit test
.PHONY: test

clean:
	@test ! -e dist || rm -rf dist
	docker-compose down --volumes --remove-orphans
.PHONY: clean

# Runs DB migrations
migrations:
	docker-compose build web
	docker-compose run web ./scripts/migrations.sh
.PHONY: migrations

# Loads sample data for the CRM
sample-data:
	docker-compose build web
	docker-compose run web bundle exec rake ffcrm:demo:load
.PHONY: sample-data

# Updates Gemfile.lock
update-gemfile:
	docker-compose build web
	docker-compose run web bundle install --no-deployment
.PHONY: update-gemfile
