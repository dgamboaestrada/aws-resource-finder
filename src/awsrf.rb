#!/usr/bin/ruby
require 'aws-sdk'
require 'optparse'
require 'thor'
require './network_interfaces'
require './target_groups'
require './route53'

class MyCLI < Thor
  class_option :verbose, :type => :boolean, :aliases => ['-v']
  class_option :profile, :default => 'default', :aliases => ['-p'], desc:'The AWS profile to use. This accepts one (-p prod) or more separated by commas (-p prod,qa)'
  class_option :region, :default => 'us-east-1', :aliases => ['-r']
  class_option :tags, :type => :boolean, :aliases => ['-t']

  desc "target_groups id", "Retrieve target groups by instance id"
  option :type, :default => 'ip', desc: 'The type to filter. Values: ip, instance, lambda.'
  def target_groups(id)
    verbose = options[:verbose]
    p options if verbose
    options[:profile].split(',').each do |profile|
      get_target_groups(profile: profile, region: options[:region], verbose: verbose, id: id, target_type: options[:type])
    end
  end

  desc "route53_records id", "Retrieve records by value"
  option :zone_name,  desc: 'The zone name in witch to search. If a zone name is no specified. if the zone is not specified, the record will be searched in all zones.'
  def route53_records(value)
    verbose = options[:verbose]
    p options if verbose
    options[:profile].split(',').each do |profile|
      puts ">>>>> Profile: #{profile}"
      get_route53_records(profile: profile, region: options[:region], verbose: verbose, zone_name: options[:zone_name], value: value)
    end
  end

  desc "network_interfaces ip profile", "the load balancer arn to filter"
  def network_interfaces(ip)
    verbose = options[:verbose]
    p options if verbose
    options[:profile].split(',').each do |profile|
      get_network_interfaces_by_private_ip(profile: profile, region: options[:region], verbose: verbose, ip: ip)
      get_network_interfaces_by_public_ip(profile: profile, region: options[:region], verbose: verbose, ip: ip)
    end
  end
end

MyCLI.start(ARGV)
