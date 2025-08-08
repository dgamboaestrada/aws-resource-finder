require 'aws-sdk-ec2'
require 'json'
require 'ostruct'
require_relative 'renderer'

def get_volume_by_id(id:, region:'us-east-1', profile:'default', verbose:false, output:'text')
  client = Aws::EC2::Client.new(profile: profile, region: region)

  begin
    resp = client.describe_volumes(volume_ids: [id])
  rescue Aws::EC2::Errors::InvalidVolumeNotFound
    resp = OpenStruct.new(volumes: [])
  end

  pp resp if verbose

  vols = resp.volumes
  if output == 'json'
    items = vols.map { |v|
      {
        id: v.volume_id,
        state: v.state,
        size_gb: v.size,
        az: v.availability_zone,
        type: v.volume_type,
        iops: v.iops,
        throughput: v.throughput,
        encrypted: v.encrypted,
        kms_key_id: v.kms_key_id,
        attachments: v.attachments.map { |a| { instance_id: a.instance_id, device: a.device, state: a.state } },
        tags: (v.tags || []).map { |t| { key: t.key, value: t.value } }
      }
    }
    render_response(
      output: output,
      command: 'volumes',
      resource: 'ec2:volume',
      profile: profile,
      region: region,
      filters: { volume_id: id },
      items: items
    )
  else
    if vols.empty?
      puts "Volume not found: #{id}"
    else
      vols.each do |v|
        att = v.attachments.first
        puts "Volume #{v.volume_id} state=#{v.state} size=#{v.size}GiB az=#{v.availability_zone} "\
             "type=#{v.volume_type} iops=#{v.iops} "\
             "attached_to=#{att&.instance_id}@#{att&.device}"
      end
    end
  end
end
