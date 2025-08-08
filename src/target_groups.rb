require 'aws-sdk-elasticloadbalancingv2'
require 'json'
require_relative 'renderer'

def get_target_groups(id:, target_type:, lb_arn:nil, region:'us-east-1', profile:'default', verbose:false, show_tags:false, output:'text')
  client = Aws::ElasticLoadBalancingV2::Client.new(profile: profile, region: region)

  marker = nil
  tgs = []
  loop do
    params = {}
    params[:load_balancer_arn] = lb_arn if lb_arn
    params[:marker] = marker if marker
    resp = client.describe_target_groups(params)
    tgs.concat(resp.target_groups)
    marker = resp.next_marker
    break unless marker
  end

  results = []

  tgs.each do |tg|
    next unless tg.target_type == target_type

    th_resp = client.describe_target_health(target_group_arn: tg.target_group_arn)

    th_resp.target_health_descriptions.each do |th|
      next unless th.target.id == id

      item = {
        target_group_arn: tg.target_group_arn,
        target_group_name: tg.target_group_name,
        target_type: tg.target_type,
        vpc_id: tg.vpc_id,
        match: {
          target_id: th.target.id,
          port: th.target.port,
          state: th.target_health.state,
          reason: th.target_health.reason,
          description: th.target_health.description
        }
      }

      if show_tags
        tags = client.describe_tags(resource_arns: [tg.target_group_arn]).tag_descriptions.first&.tags || []
        item[:tags] = tags.map { |t| { key: t.key, value: t.value } }
      end

      results << item
    end
  end

  if output == 'json'
    render_response(
      output: output,
      command: 'target_groups',
      resource: 'elbv2:target-group',
      profile: profile,
      region: region,
      filters: { target_type: target_type, id: id, lb_arn: lb_arn },
      items: results
    )
  else
    text_lines = []
    if results.empty?
      text_lines << "No matches found for id=#{id} in target groups (type=#{target_type})."
    else
      results.each do |r|
        text_lines << "TG #{r[:target_group_name]} (#{r[:target_group_arn]}) type=#{r[:target_type]} vpc=#{r[:vpc_id]} " \
                       "match=#{r[:match][:target_id]}:#{r[:match][:port]} state=#{r[:match][:state]}"
        if show_tags && r[:tags]&
          text_lines << "  tags: " + r[:tags].map { |t| "#{t[:key]}=#{t[:value]}" }.join(', ')
        end
      end
    end
    render_response(
      output: output,
      command: 'target_groups',
      resource: 'elbv2:target-group',
      profile: profile,
      region: region,
      filters: { target_type: target_type, id: id, lb_arn: lb_arn },
      items: results,
      text_lines: text_lines
    )
  end
end
