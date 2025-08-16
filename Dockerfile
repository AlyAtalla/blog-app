# syntax = docker/dockerfile:1

# -------------------------
# Base image
# -------------------------
ARG RUBY_VERSION=3.2.2
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# Set Rails environment and Bundler settings
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test"

# -------------------------
# Build stage
# -------------------------
FROM base AS build

# Install packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libvips pkg-config && \
    rm -rf /var/lib/apt/lists/*

# Copy Gemfile and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy app source code
COPY . .

# Precompile bootsnap cache for faster boot
RUN bundle exec bootsnap precompile app/ lib/

# Ensure bin files are executable
RUN chmod +x bin/* && \
    sed -i "s/\r$//g" bin/* && \
    sed -i 's/ruby\.exe$/ruby/' bin/*

# Precompile assets using the real secret key
ARG SECRET_KEY_BASE=0e29fca1439f7d2f0394e2c34d1895bc372378790a58b5d9550424f36b3a55837ae0b2cfbed6f80a6212e26ca4a3664bc320c4b4eb02cf4d800b222207121c5d
ENV SECRET_KEY_BASE=${SECRET_KEY_BASE}
RUN RAILS_ENV=production ./bin/rails assets:precompile

# -------------------------
# Final runtime stage
# -------------------------
FROM base

# Install runtime dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libvips postgresql-client && \
    rm -rf /var/lib/apt/lists/*

# Copy built gems and app code from build stage
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Add a non-root user and give permissions
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp

USER rails:rails

# Entrypoint prepares the database
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Expose default Rails port
EXPOSE 3000

# Default command
CMD ["./bin/rails", "server"]
