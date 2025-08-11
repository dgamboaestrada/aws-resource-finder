# aws-resource-finder
AWS resource finder

# Setup

## Installation
```sh
git clone git@github.com:dgamboaestrada/aws-resource-finder.git
cd aws-resource-finder/src
bundle config set path 'vendor/bundle' # (Optional) only if you do not want to do a global installation of the libraries.
bundle install
sudo ln -sf "$(pwd)/src/bin/awsrf" /usr/local/bin/awsrf
awsrf help
```

## Clean install (reset vendor)
```sh
cd src/
rm -rf vendor .bundle Gemfile.lock
bundle config set path vendor/bundle
bundle lock --add-platform ruby
bundle install --jobs=4
bundle exec ruby awsrf.rb help
```

## Uninstall
```bash
rm /usr/local/bin/awsrf
```

# Usage
```bash
./awsrf help
./awsrf target_groups -p <aws-profile> -t <ip>
./awsrf target_groups -p=prod -t --type=instance <instance-id>
./awsrf network_interfaces  <ip>
./awsrf route53_zones example.com -p prod
./awsrf route53_zones example.com -p prod,qa
./awsrf route53_records example.com --zone_name=example.com -p prod
./awsrf route53_records example.com --zone_name=example.com -p prod,qa
./awsrf volumes <id> -p dev,qa,prod
```

## Global options
- **--output=text|json|yaml**: output format. Default: `text`.
  - Examples:
    - `./awsrf route53_zones example.com -p prod --output=json`
    - `./awsrf target_groups -p prod --type=ip 10.0.0.5 --output=yaml`
- **-p, --profile=<name>[,name2]**: AWS profiles (comma-separated). Default: `default`.
  - Example: `-p prod,qa`
- **-r, --region=<aws-region>**: AWS region. Default: `us-east-1`.
- **-v, --verbose**: enables verbose mode for debugging.
- **-t, --tags**: includes tags where applicable.

# Examples

This project uses:
- [aws-sdk for ruby](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/)
- [Thor](https://github.com/rails/thor), [Wiki](https://github.com/rails/thor/wiki)

# Conventions
- [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
- [Semantic Versioning](https://semver.org/spec/v2.0.0.html)
- [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
- Git tag conventions: `git tag v0.1.0 -m "Release version 0.1.0"`

# References
- [AWS SDK for Ruby V3](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/)