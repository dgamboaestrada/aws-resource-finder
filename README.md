# aws-resource-finder
AWS resource finder

# Install
bundle config set path 'vendor/bundle' # (Optional) only if you do not want to do a global installation of the libraries.
bundle install

-  ./aws-finder target_groups -p <aws-profile> -t <ip>
-  ./aws-finder target_groups -p=bg-prod-ls -t --type=instance <instance-id>
-  ./aws-finder network_interfaces  <ip>

This project used [aws-sdk for ruby](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/)
