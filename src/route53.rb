def get_route53_records(region: 'us-east-1',  profile:'default', verbose:false, value:)
  client = Aws::Route53::Client.new(
    profile: profile,
    region: "us-east-1"
  )
  resp = client.list_resource_record_sets({
    hosted_zone_id: "Z2BRA2O9DHLC5", # required
    start_record_name: "om",
    start_record_type: "TXT", # accepts SOA, A, TXT, NS, CNAME, MX, NAPTR, PTR, SRV, SPF, AAAA, CAA, DS
#     start_record_identifier: "ResourceRecordSetIdentifier",
    max_items: 1,
  })

  resp.resource_record_sets.each do |record|
    p record
#     if tg[:target_type] == target_type
#       puts "Getting targets of type `#{target_type}` with id: `#{id}` for target group: `#{tg[:target_group_arn]}`" if verbose
#       get_target(tg[:target_group_arn], id, client)
#     end
  end
end

def get_target(target_group_arn, id, client)
  resp = client.describe_target_health({
    target_group_arn: target_group_arn,
  })
  resp[:target_health_descriptions].each do |th|
    if th[:target][:id] == id
      puts "---TG"
      puts target_group_arn
      tags = client.describe_tags({
        resource_arns: [target_group_arn]
      })
      puts tags.to_json
      puts th.to_json
    end
  end
end
