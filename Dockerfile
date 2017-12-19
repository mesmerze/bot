FROM ruby:2.3.3
ENV LANG C.UTF-8
RUN apt-get update -qq && apt-get install -y imagemagick && apt-get autoremove -y
RUN gem install bundler

RUN mkdir /code
WORKDIR /code

ADD . /code

ENV BUNDLE_PATH /bundle
ARG BUNDLE_INSTALL_OPTS
RUN bundle install $BUNDLE_INSTALL_OPTS
