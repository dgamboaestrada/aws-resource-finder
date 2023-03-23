# aws-resource-finder
AWS resource finder

# Install
bundle config set path 'vendor/bundle' # (Optional) only if you do not want to do a global installation of the libraries.
bundle install

-  ./awsrf target_groups -p <aws-profile> -t <ip>
-  ./awsrf target_groups -p=bg-prod-ls -t --type=instance <instance-id>
-  ./awsrf network_interfaces  <ip>
-  ./awsrf route53_records example.com --zone_name=example.com -p bg-prod-ls

This project used [aws-sdk for ruby](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/)
