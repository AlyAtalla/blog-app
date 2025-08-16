# syntax=docker/dockerfile:1

# -------------------------
# Base image with Ruby
# -------------------------
ARG RUBY_VERSION=3.2.2
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# Set Rails production env by default
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test"

# -------------------------
# Build stage
# -------------------------
FROM base AS build

# Install packages for gems and asset compilation
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential git libpq-dev libvips pkg-config nodejs yarn nano

# Copy Gemfiles and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy app code
COPY . .

# Precompile bootsnap code
RUN bundle exec bootsnap precompile app/ lib/

# Fix bin files for Linux
RUN chmod +x bin/* && \
    sed -i "s/\r$//g" bin/* && \
    sed -i 's/ruby\.exe$/ruby/' bin/*

# Precompile assets for production
ARG SECRET_KEY_BASE=0e29fca1439f7d2f0394e2c34d1895bc372378790a58b5d9550424f36b3a55837ae0b2cfbed6f80a6212e26ca4a3664bc320c4b4eb02cf4d800b222207121c5d
ENV SECRET_KEY_BASE=${SECRET_KEY_BASE}
RUN RAILS_ENV=production bundle exec rake assets:precompile

# -------------------------
# Final app image
# -------------------------
FROM base

# Install runtime packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl libvips postgresql-client && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Copy built gems and app code
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Create non-root user
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER rails:rails

# Entrypoint
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Expose port
EXPOSE 3000

# Start Rails server
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
