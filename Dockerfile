FROM ruby:2.3.3
ENV LANG C.UTF-8
RUN apt-get update -qq && apt-get install -y imagemagick && apt-get autoremove -y
RUN gem install bundler

RUN mkdir /code
WORKDIR /code

ADD Gemfile* /code/
ADD fat_free_crm.gemspec /code
ADD .gitignore /code
ADD vendor/gems /code/vendor/gems
ADD lib/fat_free_crm/version.rb /code/lib/fat_free_crm/version.rb
ENV BUNDLE_PATH /bundle
ENV BUNDLE_JOBS 4
ARG BUNDLE_INSTALL_OPTS
RUN bundle install $BUNDLE_INSTALL_OPTS

ADD . /code
