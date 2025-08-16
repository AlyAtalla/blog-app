# --------------------- Base Stage ---------------------
FROM ruby:3.2.2-slim AS base

# Install dependencies
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    yarn \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy Gemfiles and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle config set without 'development test'
RUN bundle install --jobs 4 --retry 3

# --------------------- Assets Stage ---------------------
FROM base AS assets

# Copy app source
COPY . .

# Set environment variables for precompile
ENV RAILS_ENV=production
ENV RAILS_SKIP_DATABASE=true
ENV SECRET_KEY_BASE=fa9e012cc6a5e32ac663547873d66986c9a22a5e2b6cead93777921c9ee9ed46330beedda43cedceae1e5d2ea9576cb135a9b35a899bd8e4824d922cf41586b

# Precompile assets
RUN bundle exec rake assets:precompile

# --------------------- Final Stage ---------------------
FROM ruby:3.2.2-slim AS final

# Install runtime dependencies
RUN apt-get update -qq && apt-get install -y \
    libpq5 \
    nodejs \
    yarn \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy gems and precompiled assets from previous stages
COPY --from=base /usr/local/bundle /usr/local/bundle
COPY --from=assets /app /app
COPY --from=assets /app/public /app/public

# Set production environment
ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_SERVE_STATIC_FILES=true

# Expose port
EXPOSE 3000

# Entrypoint to start the Rails server
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
