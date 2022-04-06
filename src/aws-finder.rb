#!/usr/bin/ruby
require 'aws-sdk'
require 'optparse'
require 'thor'
require './network_interfaces'
require './target_groups'
require './route53'

class MyCLI < Thor
  class_option :verbose, :type => :boolean, :aliases => ['-v']
  class_option :profile, :default => 'default', :aliases => ['-p']
  class_option :region, :default => 'us-east-1', :aliases => ['-r']
  class_option :tags, :type => :boolean, :aliases => ['-t']

  desc "target_groups id", "Retrieve target groups by instance id"
  option :type, :default => 'ip', desc: 'The type to filter. Values: ip, instance, lambda.'
  def target_groups(id)
    verbose = options[:verbose]
    p options if verbose
    get_target_groups(profile: options[:profile], region: options[:region], verbose: verbose, id: id, target_type: options[:type])
  end

  desc "route53_records id", "Retrieve records by value"
  def route53_records(value)
    verbose = options[:verbose]
    p options if verbose
    get_route53_records(profile: options[:profile], region: options[:region], verbose: verbose, value: value)
  end

  desc "network_interfaces ip profile", "the load balancer arn to filter"
  def network_interfaces(ip)
    verbose = options[:verbose]
    p options if verbose
    get_network_interfaces_by_private_ip(profile: options[:profile], region: options[:region], verbose: verbose, ip: ip)
    get_network_interfaces_by_public_ip(profile: options[:profile], region: options[:region], verbose: verbose, ip: ip)
  end
end

MyCLI.start(ARGV)
