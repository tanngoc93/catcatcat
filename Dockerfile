FROM ruby:3.1.2

ARG ARG_RAILS_MASTER_KEY

ENV PORT=3000 \
    RAILS_ENV=production \
    APP_DIR=/home/app/html \
    BUNDLE_PATH=/bundle/vendor \
    RAILS_MASTER_KEY=${ARG_RAILS_MASTER_KEY}

RUN apt-get update -qq \
  && apt-get install -yq --no-install-recommends \
    build-essential \
    gnupg2 \
    curl \
    less \
    git \
    libvips42 \
  && apt-get clean \
  && rm -rf /var/cache/apt/archives/* \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && truncate -s 0 /var/log/*log

RUN mkdir -p $APP_DIR $APP_DIR/log $APP_DIR/tmp/pids

RUN apt-get update -qq && apt-get install -y postgresql-client

RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - \
 && apt-get update && apt-get install -y nodejs

RUN apt-get install -y shared-mime-info

COPY Gemfile      $APP_DIR/Gemfile
COPY Gemfile.lock $APP_DIR/Gemfile.lock

WORKDIR $APP_DIR

# Application dependencies
# External Aptfile for that
COPY ./.dockerdev/Aptfile /tmp/Aptfile
RUN apt-get update -qq && apt-get -yq dist-upgrade && \
    apt-get install -yq --no-install-recommends \
    $(grep -Ev '^\s*#' /tmp/Aptfile | xargs) && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    truncate -s 0 /var/log/*log

# Configure bundler
ENV LANG=C.UTF-8 \
  BUNDLE_JOBS=4 \
  BUNDLE_RETRY=3

# Store Bundler settings in the project's root
ENV BUNDLE_APP_CONFIG=.bundle

# Upgrade RubyGems and install latest Bundler
RUN gem update --system && \
    gem install bundler && \
    bundle config set --local without 'development test' && bundle install

COPY . $APP_DIR/

RUN bundle exec rails assets:precompile

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#
EXPOSE $PORT
