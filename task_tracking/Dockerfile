ARG RUBY_VERSION=2.7.2
ARG DISTRO_NAME=buster

# Here we add the the name of the stage ("base")
FROM ruby:$RUBY_VERSION-slim-$DISTRO_NAME AS base

ARG DISTRO_NAME
ARG PG_MAJOR=13
ARG NODE_MAJOR=16
ARG YARN_VERSION=1.22.17
ARG KAFKA_URL

ENV DOCKER_DEFAULT_PLATFORM=linux/amd64
ENV KAFKA_URL=$KAFKA_URL

# Common dependencies
RUN apt-get update -qq \
  && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    build-essential \
    gnupg2 \
    curl \
    less \
    git \
    shared-mime-info \
    iputils-ping \
    telnet \
  && apt-get clean \
  && rm -rf /var/cache/apt/archives/* \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && truncate -s 0 /var/log/*log

# Install PostgreSQL dependencies
RUN curl -sSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | \
    gpg --dearmor -o /usr/share/keyrings/postgres-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/postgres-archive-keyring.gpg] https://apt.postgresql.org/pub/repos/apt/" \
    $DISTRO_NAME-pgdg main $PG_MAJOR | tee /etc/apt/sources.list.d/postgres.list > /dev/null
RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get -yq dist-upgrade && \
  DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    libpq-dev \
    postgresql-client-$PG_MAJOR \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && truncate -s 0 /var/log/*log

# Install NodeJS and Yarn
RUN curl -sL https://deb.nodesource.com/setup_$NODE_MAJOR.x | bash -
RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get -yq dist-upgrade && \
  DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    nodejs \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && truncate -s 0 /var/log/*log
RUN npm install -g yarn@$YARN_VERSION

ENV RAILS_ROOT /var/www/task_tracking

RUN gem install bundler:2.2.14

RUN mkdir -p $RAILS_ROOT && mkdir -p $RAILS_ROOT/tmp/pids
WORKDIR $RAILS_ROOT

# Install gems
COPY Gemfile* ./
RUN bundle install --jobs 20 --retry 5

COPY . .

RUN bundle exec rails assets:precompile

RUN getent group www-data || groupadd --gid 1005 www-data \
  && id -u www-data >/dev/null 2>&1 || useradd --uid 1005 --gid www-data --shell /bin/bash --create-home www-data

RUN chown -R www-data:www-data /var/www

USER www-data

CMD ["/bin/bash", "-c", "bundle exec karafka server --daemon && bundle exec rails server -b 0.0.0.0 -p 5000"]
