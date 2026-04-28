FROM ruby:3.2

# Install dependencies
RUN apt-get update -qq && apt-get install -y build-essential

# Set working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock
COPY src/Gemfile src/Gemfile.lock ./

# Install gems
RUN bundle install

# Copy the rest of the application
COPY src/ .

# Make the executable script runnable
RUN chmod +x ./bin/awsrf

# Define the entrypoint
ENTRYPOINT ["./bin/awsrf"]
