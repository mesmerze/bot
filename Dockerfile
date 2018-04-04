FROM ruby:2.4-slim

ENV LANG C.UTF-8

RUN apt-get update -qq && \
    apt-get install -y \
        build-essential \
        curl \
        git \
        apt-transport-https \
        lsb-release \
        imagemagick \
        libpq-dev \
        postgresql-client \
        libsqlite3-dev

# Add node + yarn repos
RUN curl -sS https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - >/dev/null && \
    echo "deb https://deb.nodesource.com/node_9.x jessie main" > /etc/apt/sources.list.d/nodesource.list && \
    echo "deb-src https://deb.nodesource.com/node_9.x jessie main" >> /etc/apt/sources.list.d/nodesource.list && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - >/dev/null && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list

RUN apt-get update -qq && \
    apt-get install -y \
        nodejs \
        yarn && \
    apt-get autoremove -y

RUN gem install bundler

RUN mkdir /code
COPY . /code

WORKDIR /code

CMD "./scripts/start.sh"
