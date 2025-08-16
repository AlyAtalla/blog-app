# syntax = docker/dockerfile:1

# -------------------------
# Base image
# -------------------------
ARG RUBY_VERSION=3.2.2
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# Set production environment defaults
ENV RAILS_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT="development:test" \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true

# -------------------------
# Build stage
# -------------------------
FROM base AS build

# Install system packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential git libpq-dev libvips pkg-config && \
    rm -rf /var/lib/apt/lists/*

# Copy gem files and install
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy the full app
COPY . .

# Precompile bootsnap for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Make bin files executable and fix line endings
RUN chmod +x bin/* && \
    sed -i "s/\r$//g" bin/* && \
    sed -i 's/ruby\.exe$/ruby/' bin/*

# -------------------------
# Precompile assets safely
# -------------------------
ARG SECRET_KEY_BASE=0e29fca1439f7d2f0394e2c34d1895bc372378790a58b5d9550424f36b3a55837ae0b2cfbed6f80a6212e26ca4a3664bc320c4b4eb02cf4d800b222207121c5d
ENV SECRET_KEY_BASE=${SECRET_KEY_BASE}

# Dummy DB to prevent Rails from connecting during assets precompile
ENV DATABASE_URL=postgresql://dummy:dummy@localhost:5432/dummy

RUN RAILS_ENV=production bundle exec rake assets:precompile

# -------------------------
# Final runtime stage
# -------------------------
FROM base

# Install runtime dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libvips postgresql-client && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives

# Copy built gems and app code
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Set proper permissions and create non-root user
RUN useradd -m rails && \
    chown -R rails:rails db log storage tmp

USER rails:rails

WORKDIR /rails

# Set real Railway Postgres URL at runtime
ENV DATABASE_URL=postgresql://postgres:ipAGfeooGATQNHEqZxrVTerytBEsjTqL@postgres.railway.internal:5432/railway

# Entrypoint prepares database
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Expose port 3000 and start server by default
EXPOSE 3000
CMD ["./bin/rails", "server"]
