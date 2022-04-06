def get_network_interfaces_by_private_ip(ip:, region:'us-east-1',  profile:'default', verbose:false)
  client = Aws::EC2::Client.new(
    profile: profile,
    region: "us-east-1"
  )

  resp = client.describe_network_interfaces({
    filters: [
      {
        name: "private-ip-address",
        values: [ip],
      },
    ],
  })
  p resp
end

def get_network_interfaces_by_public_ip(ip:, region:'us-east-1',  profile:'default', verbose:false)
  client = Aws::EC2::Client.new(
    profile: profile,
    region: "us-east-1"
  )

  resp = client.describe_network_interfaces({
    filters: [
      {
        name: "association.public-ip",
        values: [ip],
      },
    ],
  })
  p resp
end
