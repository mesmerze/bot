FROM ruby:2.3.3
ENV LANG C.UTF-8
RUN apt-get update -qq && apt-get install -y imagemagick && apt-get autoremove -y
RUN gem install bundler
RUN mkdir /code
RUN mkdir /code/vendor
WORKDIR /code

COPY Gemfile /code/Gemfile
COPY Gemfile.lock /code/Gemfile.lock
COPY fat_free_crm.gemspec /code/fat_free_crm.gemspec
COPY .gitignore /code/.gitignore
COPY lib /code/lib
COPY vendor/gems /code/vendor/gems
ARG BUNDLE_INSTALL_OPTS
RUN bundle install $BUNDLE_INSTALL_OPTS --deployment

COPY . /code
