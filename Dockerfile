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

# Install build dependencies including Tailwind requirements
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    git \
    libvips \
    pkg-config \
    libpq-dev \
    nodejs \
    npm \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install Yarn
RUN npm install -g yarn

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle lock --add-platform ruby && \
    bundle config set force_ruby_platform true && \
    bundle install --jobs $(nproc) --retry 3

# Install Node modules including Tailwind
COPY package.json package-lock.json ./
RUN npm install --legacy-peer-deps
RUN npm install -D tailwindcss postcss autoprefixer

# Copy application code
COPY . .

# Build arguments for secrets
ARG RAILS_MASTER_KEY
ARG SECRET_KEY_BASE

# Set environment variables
ENV RAILS_MASTER_KEY=${RAILS_MASTER_KEY} \
    SECRET_KEY_BASE=${SECRET_KEY_BASE} \
    RAILS_SKIP_DATABASE=true

# Build CSS with Tailwind
RUN npm install --legacy-peer-deps
RUN npm run build:css
RUN RAILS_ENV=production bundle exec rails assets:precompile

# --- Final image ---
FROM base

# Install runtime dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl \
    libsqlite3-0 \
    libvips \
    nodejs \
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