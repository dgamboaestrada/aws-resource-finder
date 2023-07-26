# aws-resource-finder
AWS resource finder

# Install
bundle config set path 'vendor/bundle' # (Optional) only if you do not want to do a global installation of the libraries.
bundle install

# Examples
-  ./awsrf help
-  ./awsrf target_groups -p <aws-profile> -t <ip>
-  ./awsrf target_groups -p=bg-prod-ls -t --type=instance <instance-id>
-  ./awsrf network_interfaces  <ip>
-  ./awsrf route53_records example.com --zone_name=example.com -p prod
-  ./awsrf route53_records example.com --zone_name=example.com -p prod,qa

This project used [aws-sdk for ruby](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/)
