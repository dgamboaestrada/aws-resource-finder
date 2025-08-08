require 'json'
require 'yaml'

# Standardizes JSON responses across commands.
# Generic schema v1.0
# {
#   "schema_version": "1.0",
#   "command": "<cli_subcommand>",
#   "resource": "<aws-service>:<entity>",           // e.g. "ec2:volume", "route53:record"
#   "profile": "prod",
#   "region": "us-east-1",
#   "filters": { "key": "value" },                // input filters used in the query
#   "count": 2,
#   "items": [ { /* resource-specific shape */ } ],
#   "meta": { /* extra info */ },
#   "warnings": [ "..." ],
#   "errors": [ "..." ]
# }
def render_response(output:, command:, profile:, region:, items:, verbose: false, meta: {}, warnings: [], errors: [], resource: nil, filters: {})
  return unless %w[json yaml].include?(output)

  payload = {
    schema_version: '1.0',
    command: command,
    resource: resource,
    profile: profile,
    region: region,
    filters: filters,
    count: items.respond_to?(:size) ? items.size : nil,
    items: items,
    meta: meta,
    warnings: warnings,
    errors: errors
  }

  if output == 'json'
    puts JSON.pretty_generate(payload)
  else
    puts YAML.dump(payload)
  end
end


