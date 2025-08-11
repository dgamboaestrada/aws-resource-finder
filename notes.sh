cd /Users/daniel.gamboa/Nextcloud/workspace/dgamboaestrada/aws-resource-finder/src
rm -rf vendor .bundle Gemfile.lock
bundle config set path vendor/bundle
bundle lock --add-platform ruby
bundle install --jobs=4

./bin/awsrf help
# o:
bundle exec ruby awsrf.rb help

sudo ln -sf "$(pwd)/bin/awsrf" /usr/local/bin/awsrf
awsrf help:w
