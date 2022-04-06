# aws-resource-finder
AWS resource finder

# Install
bundle config set path 'vendor/bundle' # (Optional) only if you do not want to do a global installation of the libraries.
bundle install

bundle exec ruby ./app.rb get_network_interfaces <ip>
bundle exec ruby aws-finder.rb target_groups -p <aws-profile> -t <ip>
