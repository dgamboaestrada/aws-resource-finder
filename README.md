# aws-resource-finder
AWS resource finder

# Setup

## Docker

You can run this project using Docker and Docker Compose.

### Running with Docker Compose

Ensure you have your AWS credentials configured in `~/.aws`.
An optional `.env` file can be used in the project root to manage environment variables.

```sh
docker-compose run --rm awsrf [command]
```

### Example commands with Docker

```sh
# Show help
docker-compose run --rm awsrf help

# Find target groups for an IP
docker-compose run --rm awsrf target_groups -p <aws-profile> -t <ip>

# List route53 zones
docker-compose run --rm awsrf route53_zones example.com -p prod
```


# Usage
```bash
./awsrf -v
./awsrf help
./awsrf target_groups -p <aws-profile> -t <ip>
./awsrf target_groups -p=prod -t --type=instance <instance-id>
./awsrf network_interfaces  <ip>
./awsrf route53_zones example.com -p prod
./awsrf route53_zones example.com -p prod,qa
./awsrf route53_records example.com --zone_name=example.com -p prod
./awsrf route53_records example.com --zone_name=example.com -p prod,qa
./awsrf volumes <id> -p dev,qa,prod
./awsrf acm --domain example.com -p prod
./awsrf acm --san-contains example -p prod
./awsrf acm --serial <serial_number> -p prod
```

## Global options
- **--output=text|json|yaml**: output format. Default: `text`.
  - Examples:
    - `./awsrf route53_zones example.com -p prod --output=json`
    - `./awsrf target_groups -p prod --type=ip 10.0.0.5 --output=yaml`
- **-p, --profile=<name>[,name2]**: AWS profiles (comma-separated). Default: `default`.
  - Example: `-p prod,qa`
- **-r, --region=<aws-region>**: AWS region. Default: `us-east-1`.
- **--verbose**: enables verbose mode for debugging.
- **-t, --tags**: includes tags where applicable.

### Aggregated JSON/YAML output (since 0.2.0)
When multiple profiles are provided and `--output` is `json` or `yaml`, the CLI returns a single aggregated document with this shape:

```json
{
  "schema_version": "1.0",
  "command": "<subcommand>",
  "resource": "<service>:<entity>",
  "region": "us-east-1",
  "filters": { /* input filters */ },
  "count": 3,
  "profiles": [
    {
      "profile": "prod",
      "region": "us-east-1",
      "items": [ /* results for this profile */ ],
      "warnings": [],
      "errors": []
    }
  ],
  "meta": {}
}
```

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
