# syntax = docker/dockerfile:1

ARG RUBY_VERSION=3.2.2
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

WORKDIR /rails

ENV RAILS_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT=development:test \
    RAILS_SERVE_STATIC_FILES=true \
    RAILS_LOG_TO_STDOUT=true

# --- Build stage ---
FROM base as build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libvips pkg-config libpq-dev nodejs yarn

COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3

COPY . .

RUN SECRET_KEY_BASE_DUMMY=1 RAILS_ENV=production bundle exec rails assets:precompile

# --- Final image ---
FROM base

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libsqlite3-0 libvips nodejs yarn && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp

USER rails:rails

EXPOSE 8080

ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Use the old start command (Rails default server)
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "${PORT:-8080}"]
