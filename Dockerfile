# --- Build stage ---
FROM base as build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libvips pkg-config libpq-dev nodejs npm

COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3

COPY package.json package-lock.json ./
RUN npm install --legacy-peer-deps

COPY . .

# Set Rails master key and secret key base
ARG RAILS_MASTER_KEY
ENV RAILS_MASTER_KEY=b6bfc969607086e3551703dfe80cc392
ENV SECRET_KEY_BASE=fa9e012cc6a5e32ac663547873d66986c9a22a5e2b6cead93777921c9ee9ed46330beedda43cedceae1e5d2ea9576cb135a9b35a899bd8e4824d922cf41586b
ENV RAILS_SKIP_DATABASE=true

RUN npm run build:css

# Precompile Rails assets safely (skip database & reduce memory load)
RUN RAILS_ENV=production RAILS_GROUPS=assets bundle exec rails assets:precompile


# Precompile Rails assets
RUN bundle exec rails assets:precompile

# --- Final image ---
FROM base

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libsqlite3-0 libvips nodejs npm && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Add Rails user and set permissions, including executable entrypoint
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp && \
    chmod +x /rails/bin/docker-entrypoint

USER rails:rails

EXPOSE 8080

ENTRYPOINT ["/rails/bin/docker-entrypoint"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "${PORT:-8080}"]
