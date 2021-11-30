#!/usr/bin/ruby
require 'aws-sdk'
require 'optparse'
require 'thor'
require './network_interfaces'
require './target_groups'

class MyCLI < Thor
  class_option :verbose, :type => :boolean, :aliases => ['-v']
  class_option :profile, :default => 'default', :aliases => ['-p']
  class_option :region, :default => 'us-east-1', :aliases => ['-r']
  class_option :tags, :type => :boolean, :aliases => ['-t']

  desc "target_groups_by_instance id", "Retrieve target groups by instance id"
  option :type, :default => 'ip', desc: 'The type to filter. Values: ip, instance, lambda.'
  def target_groups(id)
    p options if options[:verbose]
    get_target_groups(id: id, target_type: 'instance', profile: options[:profile], region: options[:region])
  end

  desc "network_interfaces_by_private_ip ip profile", "the load balancer arn to filter"
  def network_interfaces_by_ip(ip, profile="default")
    p options if options[:verbose]
    get_network_interfaces_by_private_ip(ip, profile)
  end
end

MyCLI.start(ARGV)
