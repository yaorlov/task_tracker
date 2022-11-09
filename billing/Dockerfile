ARG RUBY_VERSION=3.1.0
ARG DISTRO_NAME=buster

# Here we add the the name of the stage ("base")
FROM ruby:$RUBY_VERSION-slim-$DISTRO_NAME AS base

ARG DISTRO_NAME
ARG PG_MAJOR=13
ARG NODE_MAJOR=16
ARG YARN_VERSION=1.22.17

ENV DOCKER_DEFAULT_PLATFORM=linux/amd64

# Common dependencies
RUN apt-get update -qq \
  && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    build-essential \
    gnupg2 \
    curl \
    less \
    git \
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

# Install NodeJS
RUN curl -sL https://deb.nodesource.com/setup_$NODE_MAJOR.x | bash -
RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get -yq dist-upgrade && \
  DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    nodejs \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && truncate -s 0 /var/log/*log

ENV RAILS_ROOT /var/www/billing

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

CMD [\
  "/bin/bash", \
  "-c", \
  "rm -f tmp/pids/karafka && bundle exec karafka server --daemon && bundle exec rails server -b 0.0.0.0 -p 4000"\
]
