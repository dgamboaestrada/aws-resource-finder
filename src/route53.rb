require 'aws-sdk-route53'
require 'json'

def get_route53_records(region: 'us-east-1', profile:'default', verbose:false, zone_name: nil, value:, output:'text')
  client = Aws::Route53::Client.new(profile: profile, region: region)
  record_name = "#{value}."
  results = []

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
    puts "No hosted zones found#{zone_name ? " with name #{zone_name}" : ""} in Route53"
    return
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

  if output == 'json'
    puts JSON.pretty_generate(results)
  else
    if results.empty?
      puts "No records found for '#{record_name}'"
    else
      results.each do |r|
        puts "Record #{r[:name]} #{r[:type]} ttl=#{r[:ttl]} "\
             "values=#{r[:values].join(',')} alias=#{r[:alias_target]} "\
             "[zone=#{r[:zone_name]} (#{r[:zone_id]}) private=#{r[:private_zone]}]"
      end
    end
  end
end

def get_route53_zones(region: 'us-east-1', profile:'default', verbose:false, value:, output:'text')
  client = Aws::Route53::Client.new(profile: profile, region: region)
  dns_name = "#{value}."
  zones = client.list_hosted_zones_by_name(dns_name: dns_name).hosted_zones
  zones = zones.select { |z| z.name == dns_name }

  if zones.empty?
    puts "No hosted zones found with name #{dns_name}"
    return
  end

  if output == 'json'
    puts JSON.pretty_generate(zones.map { |z|
      { id: z.id, name: z.name, private_zone: z.config.private_zone }
    })
  else
    zones.each do |z|
      puts "Zone found: id=#{z.id}, name=#{z.name}, private_zone=#{z.config.private_zone}"
    end
  end
end
