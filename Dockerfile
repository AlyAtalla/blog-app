# --------------------- Base Image ---------------------
FROM ruby:3.2.2

# Install dependencies
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs yarn

# Set working directory
WORKDIR /app

# Copy Gemfiles first to leverage caching
COPY Gemfile* ./
RUN bundle install

# Copy the rest of the app
COPY . .

# --------------------- Precompile Assets ---------------------
# Prevent database connection during precompile
ENV RAILS_ENV=production
ENV RAILS_SKIP_DATABASE=true
ENV SECRET_KEY_BASE=fa9e012cc6a5e32ac663547873d66986c9a22a5e2b6cead93777921c9ee9ed46330beedda43cedceae1e5d2ea9576cb135a9b35a899bd8e4824d922cf41586b

RUN bundle exec rake assets:precompile

# --------------------- Final Stage ---------------------
# Reset skip DB for runtime
ENV RAILS_SKIP_DATABASE=false

# Expose the port your app runs on
EXPOSE 8080

# Start the server
CMD ["bin/rails", "server", "-b", "0.0.0.0", "-p", "8080"]
