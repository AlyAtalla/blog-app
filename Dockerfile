# syntax = docker/dockerfile:1

ARG RUBY_VERSION=3.2.2
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

WORKDIR /rails

ENV RAILS_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT=development:test \
    SECRET_KEY_BASE=${SECRET_KEY_BASE} \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true

# --------------------- Build Stage ---------------------
FROM base as build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libvips pkg-config

COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3

COPY . .

RUN bundle exec bootsnap precompile app/ lib/
RUN chmod +x bin/* && sed -i "s/\r$//g" bin/* && sed -i 's/ruby\.exe$/ruby/' bin/*

# Precompile assets
ENV RAILS_SKIP_DATABASE=true
RUN bundle exec rake assets:precompile

# --------------------- Final Stage ---------------------
FROM base

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libvips postgresql-client && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp

USER rails:rails

ENTRYPOINT ["/rails/bin/docker-entrypoint"]
EXPOSE 8080
CMD ["./bin/rails", "server", "-b", "0.0.0.0", "-p", "8080"]
