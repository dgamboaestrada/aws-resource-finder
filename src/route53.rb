require 'aws-sdk-route53'
require 'json'
require_relative 'renderer'

def get_route53_records(region: 'us-east-1', profile:'default', verbose:false, zone_name: nil, value:, output:'text', collect_only: false)
  client = Aws::Route53::Client.new(profile: profile, region: region)
  record_name = "#{value}."
  results = []
  warnings = []
  errors = []

  zones = []
  if zone_name && !zone_name.empty?
    dns_name = "#{zone_name}."
    hosted = client.list_hosted_zones_by_name(dns_name: dns_name, max_items: 2).hosted_zones
    hosted.each { |z| zones << z if z.name == dns_name }
  else
    marker = nil
    loop do
      resp = client.list_hosted_zones(marker: marker)
      zones.concat(resp.hosted_zones)
      marker = resp.next_marker
      break unless marker
    end
  end

  if zones.empty?
    msg = "No hosted zones found#{zone_name ? " with name #{zone_name}" : ""} in Route53"
    if collect_only
      return { resource: 'route53:record', items: [], warnings: [msg], errors: [] }
    else
      puts msg
      return
    end
  end

  zones.each do |zone|
    puts "Zone: id=#{zone.id} name=#{zone.name} private=#{zone.config.private_zone}" if verbose

    start_name = nil
    loop do
      rr = client.list_resource_record_sets(hosted_zone_id: zone.id, start_record_name: start_name)
      matches = rr.resource_record_sets.select { |r| r.name == record_name }
      matches.each do |record|
        results << {
          zone_id: zone.id,
          zone_name: zone.name,
          private_zone: zone.config.private_zone,
          name: record.name,
          type: record.type,
          ttl: record.ttl,
          values: (record.resource_records || []).map(&:value),
          alias_target: record.alias_target&.dns_name
        }
      end
      break unless rr.is_truncated
      start_name = rr.next_record_name
    end
  end

  if collect_only
    return { resource: 'route53:record', items: results, warnings: warnings, errors: errors }
  end

  text_lines = []
  if results.empty?
    text_lines << "No records found for '#{record_name}'"
  else
    results.each do |r|
      text_lines << "Record #{r[:name]} #{r[:type]} ttl=#{r[:ttl]} " \
                     "values=#{r[:values].join(',')} alias=#{r[:alias_target]} " \
                     "[zone=#{r[:zone_name]} (#{r[:zone_id]}) private=#{r[:private_zone]}]"
    end
  end
  render_response(
    output: output,
    command: 'route53_records',
    resource: 'route53:record',
    profile: profile,
    region: region,
    filters: { zone_name: zone_name, value: value },
    items: results,
    text_lines: text_lines
  )
end

def get_route53_zones(region: 'us-east-1', profile:'default', verbose:false, value:, output:'text', collect_only: false)
  client = Aws::Route53::Client.new(profile: profile, region: region)
  dns_name = "#{value}."
  zones = client.list_hosted_zones_by_name(dns_name: dns_name).hosted_zones
  zones = zones.select { |z| z.name == dns_name }

  if zones.empty?
    msg = "No hosted zones found with name #{dns_name}"
    if collect_only
      return { resource: 'route53:hosted-zone', items: [], warnings: [msg], errors: [] }
    else
      puts msg
      return
    end
  end

  items = zones.map { |z| { id: z.id, name: z.name, private_zone: z.config.private_zone } }

  if collect_only
    return { resource: 'route53:hosted-zone', items: items, warnings: [], errors: [] }
  end

  text_lines = zones.map { |z| "Zone found: id=#{z.id}, name=#{z.name}, private_zone=#{z.config.private_zone}" }
  render_response(
    output: output,
    command: 'route53_zones',
    resource: 'route53:hosted-zone',
    profile: profile,
    region: region,
    filters: { value: value },
    items: items,
    text_lines: text_lines
  )
end
