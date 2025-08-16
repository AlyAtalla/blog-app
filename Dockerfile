# syntax = docker/dockerfile:1

# Use correct Ruby version
ARG RUBY_VERSION=3.2.2
FROM ruby:$RUBY_VERSION-slim AS base

# Set Rails workdir
WORKDIR /rails

# Set production environment and Bundler options
ENV RAILS_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT="development:test"

# -------------------------
# Build stage
FROM base AS build

# Install dependencies for gems & node for assets
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libvips pkg-config curl nodejs yarn

# Copy Gemfile first for caching
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy application code
COPY . .

# Precompile bootsnap cache
RUN bundle exec bootsnap precompile app/ lib/

# Make bin files executable and fix line endings
RUN chmod +x bin/* && sed -i "s/\r$//g" bin/* && sed -i 's/ruby\.exe$/ruby/' bin/*

# Precompile assets using master key
ARG RAILS_MASTER_KEY
ENV RAILS_MASTER_KEY=${RAILS_MASTER_KEY}
RUN bundle exec rails assets:precompile

# -------------------------
# Final runtime image
FROM base

# Install runtime dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libvips postgresql-client && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Copy built gems and app from build stage
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Create non-root user
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp

USER rails:rails
WORKDIR /rails

# Entrypoint
ENTRYPOINT ["bin/docker-entrypoint"]

# Server defaults
EXPOSE 3000
CMD ["bin/rails", "server", "-b", "0.0.0.0"]
