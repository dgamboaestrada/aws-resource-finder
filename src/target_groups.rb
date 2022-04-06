def get_target_groups(id:, target_type:, lb_arn:nil, region: 'us-east-1',  profile:'default', verbose:false)
  client = Aws::ElasticLoadBalancingV2::Client.new(
    profile: profile,
    region: "us-east-1"
  )
  resp = client.describe_target_groups({
    load_balancer_arn: lb_arn
  })

  resp[:target_groups].each do |tg|
    if tg[:target_type] == target_type
      puts "Getting targets of type `#{target_type}` with id: `#{id}` for target group: `#{tg[:target_group_arn]}`" if verbose
      get_target(tg[:target_group_arn], id, client)
    end
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
