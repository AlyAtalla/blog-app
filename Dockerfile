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

# Install build dependencies (added libjemalloc2 for memory optimization)
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    git \
    libvips \
    pkg-config \
    libpq-dev \
    nodejs \
    npm \
    yarn \
    python3 \
    python3-pip \
    libjemalloc2 \
    && rm -rf /var/lib/apt/lists/*

# Install gems (with frozen lockfile verification)
COPY Gemfile Gemfile.lock ./
RUN bundle config set force_ruby_platform true && \
    bundle install --jobs $(nproc) --retry 3

# Install node modules (clean cache after)
COPY package.json package-lock.json ./
RUN npm install --legacy-peer-deps && \
    npm cache clean --force

# Copy application code (with .dockerignore support)
COPY . .

# Build arguments for secrets
ARG RAILS_MASTER_KEY
ARG SECRET_KEY_BASE

# Set environment variables (added DATABASE_URL for Railway)
ENV RAILS_MASTER_KEY=${RAILS_MASTER_KEY} \
    SECRET_KEY_BASE=${SECRET_KEY_BASE} \
    RAILS_SKIP_DATABASE=true \
    DATABASE_URL=${DATABASE_URL} \
    MALLOC_ARENA_MAX=2 \
    LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2

# Build assets (with error handling)
# Install node modules and build CSS first
RUN npm install --legacy-peer-deps
RUN npm run build:css

# Then precompile assets with debug output
RUN RAILS_ENV=production bundle exec rails assets:precompile 2>&1 | tee /tmp/assets.log || (cat /tmp/assets.log && exit 1)
# --- Final image ---
FROM base

# Install runtime dependencies (added postgres client for Railway)
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl \
    libsqlite3-0 \
    libvips \
    libjemalloc2 \
    nodejs \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Copy artifacts from build stage (explicitly copy public assets)
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails
COPY --from=build /rails/public/assets /rails/public/assets
COPY --from=build /rails/public/packs /rails/public/packs

# Setup application user and permissions (better permission handling)
RUN useradd rails --create-home --shell /bin/bash && \
    mkdir -p /rails/tmp/pids && \
    chown -R rails:rails /rails && \
    chmod +x /rails/bin/docker-entrypoint

USER rails:rails

# Health check for Railway
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:${PORT:-8080}/up || exit 1

EXPOSE ${PORT:-8080}

ENTRYPOINT ["/rails/bin/docker-entrypoint"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "${PORT:-8080}"]