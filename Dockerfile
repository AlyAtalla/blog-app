# syntax = docker/dockerfile:1

ARG RUBY_VERSION=3.2.2
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

WORKDIR /rails

ENV RAILS_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT=development:test \
    RAILS_SERVE_STATIC_FILES=true \
    RAILS_LOG_TO_STDOUT=true \
    NODE_ENV=production

# --- Build stage ---
FROM base as build

# 1. Install system dependencies with Node.js from Nodesource
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    git \
    libvips \
    pkg-config \
    libpq-dev \
    curl \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g yarn \
    && rm -rf /var/lib/apt/lists/*

# 2. Install gems first
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs $(nproc) --retry 3

# 3. Install Node modules including Tailwind
COPY package.json package-lock.json ./
RUN npm install --legacy-peer-deps
RUN npm install -D tailwindcss postcss autoprefixer @tailwindcss/forms @tailwindcss/typography

# Verify Tailwind installation
RUN ls -la node_modules/.bin/tailwindcss || echo "Tailwind CLI not found!"

# 4. Copy application code
COPY . .

# Build arguments for secrets
ARG RAILS_MASTER_KEY
ARG SECRET_KEY_BASE

# Set environment variables
ENV RAILS_MASTER_KEY=${RAILS_MASTER_KEY} \
    SECRET_KEY_BASE=${SECRET_KEY_BASE} \
    RAILS_SKIP_DATABASE=true

# 5. Build CSS using npm script
RUN npm run build:css

# 6. Precompile assets
RUN RAILS_ENV=production bundle exec rails assets:precompile

# --- Final image ---
FROM base

# Install runtime dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl \
    libsqlite3-0 \
    libvips \
    && rm -rf /var/lib/apt/lists/*

# Copy artifacts from build stage
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Setup application user and permissions
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp && \
    chmod +x /rails/bin/docker-entrypoint

USER rails:rails

EXPOSE ${PORT:-8080}

ENTRYPOINT ["/rails/bin/docker-entrypoint"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "${PORT:-8080}"]