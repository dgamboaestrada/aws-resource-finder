def get_route53_records(region: 'us-east-1',  profile:'default', verbose:false, zone_name:, value:)
  search_records_in_zone_by_name(verbose, profile, region, "#{zone_name}.", "#{value}.")
end

def get_route53_zones(region: 'us-east-1',  profile:'default', verbose:false, value:)
  search_zones_by_name(verbose, profile, region, "#{value}.")
end

def search_zones_by_name(verbose, profile, region, zone_name)
  client = Aws::Route53::Client.new(profile: profile, region: region)

  zone = client.list_hosted_zones_by_name(dns_name: zone_name).hosted_zones.first
  pp zone if verbose

  if zone.empty? || zone.name != zone_name
    puts "No zone was found with the name #{zone_name} in Route53"
    return
  end
  puts "Zone found: #{zone.id}, #{zone.name}"
end

def search_records_in_zone_by_name(verbose, profile, region, zone_name, record_name)
  client = Aws::Route53::Client.new(profile: profile, region: region)

  hosted_zones = client.list_hosted_zones_by_name(dns_name: zone_name, max_items: 2).hosted_zones
  pp hosted_zones if verbose

  # Check if the zone is the first or the last in the list (public and private zones).
  zones = []
  if hosted_zones.empty? || hosted_zones.first.name == zone_name
    zones.push(hosted_zones.first)
  end
  if hosted_zones.length > 1 && hosted_zones.last.name == zone_name
    zones.push(hosted_zones.last)
  end

  if zones.empty?
    puts "No zone was found with the name #{zone_name} in Route53"
    return
  end

  zones.each do |zone|
    puts "Zone found. id: #{zone.id}, name: #{zone.name}, private_zone: #{zone.config.private_zone}"
    resp = client.list_resource_record_sets(hosted_zone_id: zone.id, max_items: 300)
    puts "Records for #{zone}" if verbose
    pp resp if verbose

    found_records = resp.resource_record_sets.select { |record| record.name == record_name }
    pp found_records if verbose

    if found_records.empty?
      puts "No records were found with the name #{record_name} in zone #{zone_name}"
    end

    found_records.each do |record|
      puts "Record found: #{record.name} #{record.type} #{record.ttl} #{record.resource_records.map(&:value)} #{record.alias_target.dns_name if record.alias_target != nil}"
    end
  end
end
