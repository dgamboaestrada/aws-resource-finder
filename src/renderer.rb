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
def render_response(output:, command:, profile:, region:, items:, verbose: false, meta: {}, warnings: [], errors: [], resource: nil, filters: {}, text_lines: nil)
  unless %w[text json yaml].include?(output)
    return
  end

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

  if output == 'text'
    header = [
      "command=#{command}",
      ("resource=#{resource}" unless resource.nil? || resource.to_s.empty?),
      ("profile=#{profile}" unless profile.nil? || profile.to_s.empty?),
      ("region=#{region}" unless region.nil? || region.to_s.empty?),
      ("count=#{payload[:count]}"),
      ("filters=#{filters.compact.to_h.to_json}" unless filters.nil? || filters.empty?)
    ].compact.join(' ')
    puts header
    warnings.each { |w| puts "warning: #{w}" }
    errors.each { |e| puts "error: #{e}" }
    if text_lines && !text_lines.empty?
      text_lines.each { |l| puts l }
    else
      # Fallback: dump items in a compact JSON per line
      Array(items).each { |it| puts JSON.generate(it) }
    end
  elsif output == 'json'
    puts JSON.pretty_generate(payload)
  else
    puts YAML.dump(payload)
  end
end

def render_aggregated_response(output:, command:, resource:, region:, filters:, profiles:, meta: {})
  unless %w[text json yaml].include?(output)
    return
  end

  if output == 'text'
    # For aggregated text, print a compact summary per profile
    total = profiles.reduce(0) { |acc, p| acc + (p[:items]&.size || 0) }
    header = [
      "command=#{command}",
      ("resource=#{resource}" unless resource.nil? || resource.to_s.empty?),
      ("region=#{region}" unless region.nil? || region.to_s.empty?),
      ("count=#{total}"),
      ("filters=#{filters.compact.to_h.to_json}" unless filters.nil? || filters.empty?)
    ].compact.join(' ')
    puts header
    profiles.each do |p|
      puts "profile=#{p[:profile]} region=#{p[:region]} count=#{p[:items]&.size || 0}"
      Array(p[:warnings]).each { |w| puts "warning: #{w}" }
      Array(p[:errors]).each { |e| puts "error: #{e}" }
      Array(p[:items]).each { |it| puts JSON.generate(it) }
    end
    return
  end

  total_count = profiles.reduce(0) { |acc, p| acc + (p[:items]&.size || 0) }
  payload = {
    schema_version: '1.0',
    command: command,
    resource: resource,
    region: region,
    filters: filters,
    count: total_count,
    profiles: profiles,
    meta: meta
  }

  if output == 'json'
    puts JSON.pretty_generate(payload)
  else
    puts YAML.dump(payload)
  end
end


