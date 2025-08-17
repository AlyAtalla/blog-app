# syntax=docker/dockerfile:1

ARG RUBY_VERSION=3.2.2
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

ENV RAILS_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT=development:test \
    RAILS_SERVE_STATIC_FILES=true \
    RAILS_LOG_TO_STDOUT=true \
    NODE_ENV=production

# --- Build stage ---
FROM base AS build

# 1. Install system dependencies + Node.js
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential git libvips pkg-config libpq-dev curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs npm && \
    rm -rf /var/lib/apt/lists/*

# 2. Copy and install Ruby gems
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs $(nproc) --retry 3

# 3. Copy Node package files and install dependencies
COPY package.json package-lock.json ./
RUN npm install --legacy-peer-deps
RUN npm install -D tailwindcss postcss autoprefixer @tailwindcss/forms @tailwindcss/typography

# 4. Copy application code
COPY . .

# 5. Ensure builds folder exists
RUN mkdir -p ./app/assets/builds

# 6. Set secrets (build args)
ARG RAILS_MASTER_KEY
ARG SECRET_KEY_BASE
ENV RAILS_MASTER_KEY=${RAILS_MASTER_KEY} \
    SECRET_KEY_BASE=${SECRET_KEY_BASE} \
    RAILS_SKIP_DATABASE=true

# 7. Build Tailwind CSS
RUN npx tailwindcss -i ./app/assets/stylesheets/application.tailwind.css \
    -o ./app/assets/builds/application.css --minify

# 8. Precompile Rails assets
RUN RAILS_ENV=production bundle exec rails assets:precompile

# --- Final stage ---
FROM base

# 9. Install runtime dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libsqlite3-0 libvips && \
    rm -rf /var/lib/apt/lists/*

# 10. Copy artifacts from build stage
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# 11. Setup user and permissions
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp && \
    chmod +x /rails/bin/docker-entrypoint

USER rails:rails

EXPOSE ${PORT:-8080}

ENTRYPOINT ["/rails/bin/docker-entrypoint"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "${PORT:-8080}"]
