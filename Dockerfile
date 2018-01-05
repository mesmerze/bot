FROM ruby:2.4

ENV LANG C.UTF-8

RUN apt-get update -qq && apt-get install -y \
    imagemagick \
    && apt-get autoremove -y

RUN gem install bundler

RUN mkdir /code
WORKDIR /code

ADD . /code
