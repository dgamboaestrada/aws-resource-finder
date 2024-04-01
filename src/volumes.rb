require 'aws-sdk-ec2'

def get_volume_by_id(id:, region:'us-east-1',  profile:'default', verbose:false)
  client = Aws::EC2::Client.new(
    profile: profile,
    region: "us-east-1"
  )

  begin
    resp = client.describe_volumes(volume_ids: [id])
  rescue Aws::EC2::Errors::InvalidVolumeNotFound
    resp = []
  end
    p resp

#   volumes.each do |volume|
#     puts volume.volume_id
#   end
end
