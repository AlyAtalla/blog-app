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
    apt-get install --no-install-recommends -y build-essential git libvips pkg-config libpq-dev nodejs npm yarn

COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3

COPY package.json package-lock.json ./
RUN npm install --legacy-peer-deps

COPY . .

ARG RAILS_MASTER_KEY
ENV RAILS_MASTER_KEY=${RAILS_MASTER_KEY}
ENV SECRET_KEY_BASE=${SECRET_KEY_BASE:-dummy}
ENV RAILS_SKIP_DATABASE=true

RUN npm run build:css
RUN RAILS_ENV=production RAILS_GROUPS=assets bundle exec rails assets:precompile
# --- Final image ---
FROM base


RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libsqlite3-0 libvips nodejs npm && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Add Rails user and set permissions, including executable entrypoint
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp && \
    chmod +x /rails/bin/docker-entrypoint

USER rails:rails

EXPOSE 8080

ENTRYPOINT ["/rails/bin/docker-entrypoint"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "${PORT:-8080}"]
