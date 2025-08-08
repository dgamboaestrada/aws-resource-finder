#!/usr/bin/ruby
require 'aws-sdk'
require 'optparse'
require 'thor'
require 'json'

require_relative 'network_interfaces'
require_relative 'target_groups'
require_relative 'route53'
require_relative 'volumes'
require_relative 'acm'

class MyCLI < Thor
  class_option :verbose, :type => :boolean, :aliases => ['-v']
  class_option :profile, :default => 'default', :aliases => ['-p'], desc:'AWS profile(s), e.g., -p prod or -p prod,qa'
  class_option :region, :default => 'us-east-1', :aliases => ['-r']
  class_option :tags, :type => :boolean, :aliases => ['-t'], desc: 'Show tags where applicable'
  class_option :output, :default => 'text', desc: 'Output format (text|json)'

  desc "target_groups ID", "Search Target Groups by target ID (instance/ip/lambda)"
  option :type, :default => 'ip', desc: 'Target type (ip|instance|lambda)'
  option :lb_arn, desc: 'Optional Load Balancer ARN to filter target groups'
  def target_groups(id)
    verbose = options[:verbose]
    p options if verbose
    options[:profile].split(',').map(&:strip).each do |profile|
      get_target_groups(
        profile: profile,
        region: options[:region],
        verbose: verbose,
        id: id,
        target_type: options[:type],
        lb_arn: options[:lb_arn],
        show_tags: options[:tags],
        output: options[:output]
      )
    end
  end

  desc "route53_zones VALUE", "Find hosted zones by exact name"
  def route53_zones(value)
    verbose = options[:verbose]
    p options if verbose
    options[:profile].split(',').map(&:strip).each do |profile|
      puts ">>>>> Profile: #{profile}"
      get_route53_zones(profile: profile, region: options[:region], verbose: verbose, value: value, output: options[:output])
    end
  end

  desc "route53_records VALUE", "Find records by name. If --zone-name is omitted, search across all zones."
  option :zone_name,  desc: 'Optional hosted zone name to restrict the search'
  def route53_records(value)
    verbose = options[:verbose]
    p options if verbose
    options[:profile].split(',').map(&:strip).each do |profile|
      puts ">>>>> Profile: #{profile}"
      get_route53_records(profile: profile, region: options[:region], verbose: verbose, zone_name: options[:zone_name], value: value, output: options[:output])
    end
  end

  desc "network_interfaces IP", "Find ENIs by private/public IP"
  def network_interfaces(ip)
    verbose = options[:verbose]
    p options if verbose
    options[:profile].split(',').map(&:strip).each do |profile|
      puts ">>>>> Profile: #{profile}"
      get_network_interfaces_by_private_ip(profile: profile, region: options[:region], verbose: verbose, ip: ip, output: options[:output])
      get_network_interfaces_by_public_ip(profile: profile, region: options[:region], verbose: verbose, ip: ip, output: options[:output])
    end
  end

  desc "volumes ID", "Find EBS volumes by ID"
  def volumes(id)
    verbose = options[:verbose]
    p options if verbose
    options[:profile].split(',').map(&:strip).each do |profile|
      puts ">>>>> Profile: #{profile}"
      get_volume_by_id(profile: profile, region: options[:region], verbose: verbose, id: id, output: options[:output])
    end
  end

  desc "acm", "Search ACM certificates by --domain, --san-contains or --serial"
  option :domain, desc: 'Certificate common name (exact domain)'
  option :san_contains, desc: 'Substring to search within Subject Alternative Names'
  option :serial, desc: 'Certificate serial number (hex)'
  def acm
    verbose = options[:verbose]
    if [options[:domain], options[:san_contains], options[:serial]].compact.empty?
      abort("You must specify at least one: --domain, --san-contains or --serial")
    end
    options[:profile].split(',').map(&:strip).each do |profile|
      puts ">>>>> Profile: #{profile}"
      search_acm(
        profile: profile,
        region: options[:region],
        domain: options[:domain],
        san_contains: options[:san_contains],
        serial: options[:serial],
        verbose: verbose,
        output: options[:output]
      )
    end
  end
end

MyCLI.start(ARGV)
