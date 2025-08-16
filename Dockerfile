# syntax = docker/dockerfile:1

ARG RUBY_VERSION=3.2.2
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

ENV RAILS_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT="development:test" \
    RAILS_SERVE_STATIC_FILES=true

# -------------------------
# Build stage
# -------------------------
FROM base AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libvips pkg-config

COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

COPY . .

# Precompile bootsnap
RUN bundle exec bootsnap precompile app/ lib/

# Adjust bin files
RUN chmod +x bin/* && \
    sed -i "s/\r$//g" bin/* && \
    sed -i 's/ruby\.exe$/ruby/' bin/*

# -------------------------
# Precompile assets without database
# -------------------------
ARG SECRET_KEY_BASE
ENV SECRET_KEY_BASE=${SECRET_KEY_BASE}
ENV RAILS_SKIP_DATABASE=true

RUN bundle exec rails assets:precompile

# -------------------------
# Final runtime image
# -------------------------
FROM base

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libvips postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER rails:rails

EXPOSE 3000
ENTRYPOINT ["/rails/bin/docker-entrypoint"]
CMD ["./bin/rails", "server"]
