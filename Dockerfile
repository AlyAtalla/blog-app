# --- Build stage ---
FROM ruby:3.2 AS build

WORKDIR /rails

# 1. Install dependencies
RUN apt-get update -qq && apt-get install --no-install-recommends -y \
    build-essential git libvips pkg-config libpq-dev curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs npm && \
    rm -rf /var/lib/apt/lists/*

# 2. Install Ruby gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# 3. Install JS deps
COPY package.json package-lock.json ./
RUN npm install

# 4. Copy project files
COPY . .

# 5. Build Tailwind
RUN npm run build:css

# --- Final stage ---
FROM ruby:3.2-slim

WORKDIR /rails

# Install runtime dependencies
RUN apt-get update -qq && apt-get install --no-install-recommends -y \
    libpq-dev libvips curl && \
    rm -rf /var/lib/apt/lists/*

# Copy only what’s needed
COPY --from=build /rails /rails

# Ensure built CSS is present
COPY --from=build /rails/app/assets/builds /rails/app/assets/builds

EXPOSE 3000

CMD ["bin/rails", "server", "-b", "0.0.0.0"]
