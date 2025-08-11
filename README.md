# aws-resource-finder
AWS resource finder

# Install
```bash
git clone git@github.com:dgamboaestrada/aws-resource-finder.git
cd aws-resource-finder/src
bundle config set path 'vendor/bundle' # (Optional) only if you do not want to do a global installation of the libraries.
bundle install
ln -s $(pwd)/bin/awsrf /usr/local/bin/awsrf
```

# Uninstall
```bash
rm /usr/local/bin/awsrf
```

# Usage
```bash
./awsrf help
./awsrf target_groups -p <aws-profile> -t <ip>
./awsrf target_groups -p=bg-prod-ls -t --type=instance <instance-id>
./awsrf network_interfaces  <ip>
./awsrf route53_zones example.com -p prod
./awsrf route53_zones example.com -p prod,qa
./awsrf route53_records example.com --zone_name=example.com -p prod
./awsrf route53_records example.com --zone_name=example.com -p prod,qa
./awsrf volumes <id> -p dev,qa,prod
```

# Examples

This project used:
- [aws-sdk for ruby](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/)
- [Thor](https://github.com/rails/thor), [Wiki](https://github.com/rails/thor/wiki)

# Conventions
- [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
- [Semantic Versioning](https://semver.org/spec/v2.0.0.html)
- [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
- Git tag conventions: `git tag v0.1.0 -m "Release version 0.1.0"`

# References
- [AWS SDK for Ruby V3](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/)