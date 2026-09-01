FROM ruby:3.3.9-alpine

RUN apk add --no-cache build-base nodejs yarn postgresql-dev tzdata bash libxml2-dev libxslt-dev

WORKDIR /app

# Install gems
COPY Gemfile Gemfile.lock* ./
RUN gem install bundler && bundle config set without 'development test' && bundle install --jobs 4 --retry 3

# Copy the app
COPY . .

ENV RAILS_ENV=production
ENV RAILS_SERVE_STATIC_FILES=true
ENV RAILS_LOG_TO_STDOUT=true

RUN bundle exec rake assets:precompile || true

EXPOSE 8080

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
