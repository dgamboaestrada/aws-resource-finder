require 'aws-sdk-ec2'
require 'json'

def get_network_interfaces_by_private_ip(ip:, region:'us-east-1', profile:'default', verbose:false, output:'text')
  client = Aws::EC2::Client.new(profile: profile, region: region)

  resp = client.describe_network_interfaces(filters: [{ name: "private-ip-address", values: [ip] }])
  pp resp if verbose

  render_network_interfaces(resp.network_interfaces, output: output)
end

def get_network_interfaces_by_public_ip(ip:, region:'us-east-1', profile:'default', verbose:false, output:'text')
  client = Aws::EC2::Client.new(profile: profile, region: region)

  resp = client.describe_network_interfaces(filters: [{ name: "association.public-ip", values: [ip] }])
  pp resp if verbose

  render_network_interfaces(resp.network_interfaces, output: output)
end

def render_network_interfaces(enis, output: 'text')
  if output == 'json'
    puts JSON.pretty_generate(enis.map { |ni|
      {
        id: ni.network_interface_id,
        status: ni.status,
        private_ip: ni.private_ip_address,
        public_ip: ni.association&.public_ip,
        subnet_id: ni.subnet_id,
        vpc_id: ni.vpc_id,
        attachment_instance_id: ni.attachment&.instance_id,
        description: ni.description,
        groups: ni.groups.map { |g| { id: g.group_id, name: g.group_name } },
        tags: (ni.tag_set || []).map { |t| { key: t.key, value: t.value } }
      }
    })
  else
    if enis.empty?
      puts "No ENIs found."
    else
      enis.each do |ni|
        puts "ENI #{ni.network_interface_id} (#{ni.status}) "\
             "private=#{ni.private_ip_address} public=#{ni.association&.public_ip} "\
             "subnet=#{ni.subnet_id} vpc=#{ni.vpc_id} attached_to=#{ni.attachment&.instance_id}"
      end
    end
  end
end
