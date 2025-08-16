# --------------------- Base Stage ---------------------
FROM ruby:3.2.2-slim AS base

# Install dependencies
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs yarn nano

# Set working directory
WORKDIR /app

# Copy Gemfile and install gems
COPY Gemfile Gemfile.lock ./
RUN gem install bundler -v 2.4.22
RUN bundle install --jobs 4 --retry 3

# --------------------- Build Stage ---------------------
FROM base AS build

# Copy app source code
COPY . .

# Set environment variables
ENV RAILS_ENV=production
ENV RAILS_MASTER_KEY=b6bfc969607086e3551703dfe80cc392
ENV DATABASE_URL=postgresql://postgres:0120852868@localhost/bolg_app_production

# Precompile assets
RUN bundle exec rails assets:precompile

# --------------------- Final Stage ---------------------
FROM ruby:3.2.2-slim AS final

WORKDIR /app

# Copy gems and app from build
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /app /app

# Set environment variables
ENV RAILS_ENV=production
ENV RAILS_MASTER_KEY=b6bfc969607086e3551703dfe80cc392
ENV RAILS_LOG_TO_STDOUT=true
ENV DATABASE_URL=postgresql://postgres:0120852868@localhost/bolg_app_production

# Expose port
EXPOSE 3000

# Start Puma server
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
