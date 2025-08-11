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
require_relative 'renderer'

class MyCLI < Thor
  class_option :verbose, :type => :boolean, :aliases => ['-v']
  class_option :profile, :default => 'default', :aliases => ['-p'], desc:'AWS profile(s), e.g., -p prod or -p prod,qa'
  class_option :region, :default => 'us-east-1', :aliases => ['-r']
  class_option :tags, :type => :boolean, :aliases => ['-t'], desc: 'Show tags where applicable'
  class_option :output, :default => 'text', desc: 'Output format (text|json|yaml)'

  desc "target_groups ID", "Search Target Groups by target ID (instance/ip/lambda)"
  option :type, :default => 'ip', desc: 'Target type (ip|instance|lambda)'
  option :lb_arn, desc: 'Optional Load Balancer ARN to filter target groups'
  def target_groups(id)
    verbose = options[:verbose]
    p options if verbose
    if %w[json yaml].include?(options[:output])
      aggregated = []
      options[:profile].split(',').map(&:strip).each do |profile|
        begin
          res = get_target_groups(
            profile: profile,
            region: options[:region],
            verbose: verbose,
            id: id,
            target_type: options[:type],
            lb_arn: options[:lb_arn],
            show_tags: options[:tags],
            output: options[:output],
            collect_only: true
          )
          aggregated << { profile: profile, region: options[:region], items: res[:items], warnings: res[:warnings], errors: res[:errors] }
        rescue ArgumentError => e
          message = (e.message =~ /Cached SSO Token is expired/i) ? "AWS SSO token expired for profile #{profile}. Run: aws sso login --profile #{profile}" : e.message
          aggregated << { profile: profile, region: options[:region], items: [], warnings: [], errors: [message] }
        rescue Aws::Errors::MissingCredentialsError
          message = "Missing AWS credentials for profile #{profile}. Set AWS_PROFILE or run: aws configure sso --profile #{profile}"
          aggregated << { profile: profile, region: options[:region], items: [], warnings: [], errors: [message] }
        rescue StandardError => e
          aggregated << { profile: profile, region: options[:region], items: [], warnings: [], errors: [e.class.name + ': ' + e.message] }
        end
      end
      render_aggregated_response(output: options[:output], command: 'target_groups', resource: 'elbv2:target-group', region: options[:region], filters: { id: id, target_type: options[:type], lb_arn: options[:lb_arn] }, profiles: aggregated)
    else
      options[:profile].split(',').map(&:strip).each do |profile|
        puts ">>>>> Profile: #{profile}"
        execute_with_aws_errors(command: 'target_groups', profile: profile, region: options[:region], output: options[:output]) do
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
    end
  end

  desc "route53_zones VALUE", "Find hosted zones by exact name"
  def route53_zones(value)
    verbose = options[:verbose]
    p options if verbose
    if %w[json yaml].include?(options[:output])
      aggregated = []
      options[:profile].split(',').map(&:strip).each do |profile|
        begin
          res = get_route53_zones(profile: profile, region: options[:region], verbose: verbose, value: value, output: options[:output], collect_only: true)
          aggregated << { profile: profile, region: options[:region], items: res[:items], warnings: res[:warnings], errors: res[:errors] }
        rescue ArgumentError => e
          message = (e.message =~ /Cached SSO Token is expired/i) ? "AWS SSO token expired for profile #{profile}. Run: aws sso login --profile #{profile}" : e.message
          aggregated << { profile: profile, region: options[:region], items: [], warnings: [], errors: [message] }
        rescue Aws::Errors::MissingCredentialsError
          message = "Missing AWS credentials for profile #{profile}. Set AWS_PROFILE or run: aws configure sso --profile #{profile}"
          aggregated << { profile: profile, region: options[:region], items: [], warnings: [], errors: [message] }
        rescue StandardError => e
          aggregated << { profile: profile, region: options[:region], items: [], warnings: [], errors: [e.class.name + ': ' + e.message] }
        end
      end
      render_aggregated_response(output: options[:output], command: 'route53_zones', resource: 'route53:hosted-zone', region: options[:region], filters: { value: value }, profiles: aggregated)
    else
      options[:profile].split(',').map(&:strip).each do |profile|
        puts ">>>>> Profile: #{profile}"
        execute_with_aws_errors(command: 'route53_zones', profile: profile, region: options[:region], output: options[:output], filters: { value: value }) do
          get_route53_zones(profile: profile, region: options[:region], verbose: verbose, value: value, output: options[:output])
        end
      end
    end
  end

  desc "route53_records VALUE", "Find records by name. If --zone-name is omitted, search across all zones."
  option :zone_name,  desc: 'Optional hosted zone name to restrict the search'
  def route53_records(value)
    verbose = options[:verbose]
    p options if verbose
    if %w[json yaml].include?(options[:output])
      aggregated = []
      options[:profile].split(',').map(&:strip).each do |profile|
        begin
          res = get_route53_records(profile: profile, region: options[:region], verbose: verbose, zone_name: options[:zone_name], value: value, output: options[:output], collect_only: true)
          aggregated << { profile: profile, region: options[:region], items: res[:items], warnings: res[:warnings], errors: res[:errors] }
        rescue ArgumentError => e
          message = (e.message =~ /Cached SSO Token is expired/i) ? "AWS SSO token expired for profile #{profile}. Run: aws sso login --profile #{profile}" : e.message
          aggregated << { profile: profile, region: options[:region], items: [], warnings: [], errors: [message] }
        rescue Aws::Errors::MissingCredentialsError
          message = "Missing AWS credentials for profile #{profile}. Set AWS_PROFILE or run: aws configure sso --profile #{profile}"
          aggregated << { profile: profile, region: options[:region], items: [], warnings: [], errors: [message] }
        rescue StandardError => e
          aggregated << { profile: profile, region: options[:region], items: [], warnings: [], errors: [e.class.name + ': ' + e.message] }
        end
      end
      render_aggregated_response(output: options[:output], command: 'route53_records', resource: 'route53:record', region: options[:region], filters: { value: value, zone_name: options[:zone_name] }, profiles: aggregated)
    else
      options[:profile].split(',').map(&:strip).each do |profile|
        puts ">>>>> Profile: #{profile}"
        execute_with_aws_errors(command: 'route53_records', profile: profile, region: options[:region], output: options[:output], filters: { value: value, zone_name: options[:zone_name] }) do
          get_route53_records(profile: profile, region: options[:region], verbose: verbose, zone_name: options[:zone_name], value: value, output: options[:output])
        end
      end
    end
  end

  desc "network_interfaces IP", "Find ENIs by private/public IP"
  def network_interfaces(ip)
    verbose = options[:verbose]
    p options if verbose
    if %w[json yaml].include?(options[:output])
      aggregated = []
      options[:profile].split(',').map(&:strip).each do |profile|
        begin
          res_priv = get_network_interfaces_by_private_ip(profile: profile, region: options[:region], verbose: verbose, ip: ip, output: options[:output], collect_only: true)
          res_pub  = get_network_interfaces_by_public_ip(profile: profile, region: options[:region], verbose: verbose, ip: ip, output: options[:output], collect_only: true)
          items = Array(res_priv[:items]) + Array(res_pub[:items])
          warnings = Array(res_priv[:warnings]) + Array(res_pub[:warnings])
          errors = Array(res_priv[:errors]) + Array(res_pub[:errors])
          aggregated << { profile: profile, region: options[:region], items: items, warnings: warnings, errors: errors }
        rescue ArgumentError => e
          message = (e.message =~ /Cached SSO Token is expired/i) ? "AWS SSO token expired for profile #{profile}. Run: aws sso login --profile #{profile}" : e.message
          aggregated << { profile: profile, region: options[:region], items: [], warnings: [], errors: [message] }
        rescue Aws::Errors::MissingCredentialsError
          message = "Missing AWS credentials for profile #{profile}. Set AWS_PROFILE or run: aws configure sso --profile #{profile}"
          aggregated << { profile: profile, region: options[:region], items: [], warnings: [], errors: [message] }
        rescue StandardError => e
          aggregated << { profile: profile, region: options[:region], items: [], warnings: [], errors: [e.class.name + ': ' + e.message] }
        end
      end
      render_aggregated_response(output: options[:output], command: 'network_interfaces', resource: 'ec2:network-interface', region: options[:region], filters: { ip: ip }, profiles: aggregated)
    else
      options[:profile].split(',').map(&:strip).each do |profile|
        puts ">>>>> Profile: #{profile}"
        execute_with_aws_errors(command: 'network_interfaces', profile: profile, region: options[:region], output: options[:output], filters: { ip: ip }) do
          get_network_interfaces_by_private_ip(profile: profile, region: options[:region], verbose: verbose, ip: ip, output: options[:output])
          get_network_interfaces_by_public_ip(profile: profile, region: options[:region], verbose: verbose, ip: ip, output: options[:output])
        end
      end
    end
  end

  desc "volumes ID", "Find EBS volumes by ID"
  def volumes(id)
    verbose = options[:verbose]
    p options if verbose
    if %w[json yaml].include?(options[:output])
      aggregated = []
      options[:profile].split(',').map(&:strip).each do |profile|
        begin
          res = get_volume_by_id(profile: profile, region: options[:region], verbose: verbose, id: id, output: options[:output], collect_only: true)
          aggregated << { profile: profile, region: options[:region], items: res[:items], warnings: res[:warnings], errors: res[:errors] }
        rescue ArgumentError => e
          message = (e.message =~ /Cached SSO Token is expired/i) ? "AWS SSO token expired for profile #{profile}. Run: aws sso login --profile #{profile}" : e.message
          aggregated << { profile: profile, region: options[:region], items: [], warnings: [], errors: [message] }
        rescue Aws::Errors::MissingCredentialsError
          message = "Missing AWS credentials for profile #{profile}. Set AWS_PROFILE or run: aws configure sso --profile #{profile}"
          aggregated << { profile: profile, region: options[:region], items: [], warnings: [], errors: [message] }
        rescue StandardError => e
          aggregated << { profile: profile, region: options[:region], items: [], warnings: [], errors: [e.class.name + ': ' + e.message] }
        end
      end
      render_aggregated_response(output: options[:output], command: 'volumes', resource: 'ec2:volume', region: options[:region], filters: { id: id }, profiles: aggregated)
    else
      options[:profile].split(',').map(&:strip).each do |profile|
        puts ">>>>> Profile: #{profile}"
        execute_with_aws_errors(command: 'volumes', profile: profile, region: options[:region], output: options[:output], filters: { id: id }) do
          get_volume_by_id(profile: profile, region: options[:region], verbose: verbose, id: id, output: options[:output])
        end
      end
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
    if %w[json yaml].include?(options[:output])
      aggregated = []
      options[:profile].split(',').map(&:strip).each do |profile|
        begin
          res = search_acm(
            profile: profile,
            region: options[:region],
            domain: options[:domain],
            san_contains: options[:san_contains],
            serial: options[:serial],
            verbose: verbose,
            output: options[:output],
            collect_only: true
          )
          aggregated << { profile: profile, region: options[:region], items: res[:items], warnings: res[:warnings], errors: res[:errors] }
        rescue ArgumentError => e
          message = (e.message =~ /Cached SSO Token is expired/i) ? "AWS SSO token expired for profile #{profile}. Run: aws sso login --profile #{profile}" : e.message
          aggregated << { profile: profile, region: options[:region], items: [], warnings: [], errors: [message] }
        rescue Aws::Errors::MissingCredentialsError
          message = "Missing AWS credentials for profile #{profile}. Set AWS_PROFILE or run: aws configure sso --profile #{profile}"
          aggregated << { profile: profile, region: options[:region], items: [], warnings: [], errors: [message] }
        rescue StandardError => e
          aggregated << { profile: profile, region: options[:region], items: [], warnings: [], errors: [e.class.name + ': ' + e.message] }
        end
      end
      render_aggregated_response(output: options[:output], command: 'acm', resource: 'acm:certificate', region: options[:region], filters: { domain: options[:domain], san_contains: options[:san_contains], serial: options[:serial] }, profiles: aggregated)
    else
      options[:profile].split(',').map(&:strip).each do |profile|
        puts ">>>>> Profile: #{profile}"
        execute_with_aws_errors(command: 'acm', profile: profile, region: options[:region], output: options[:output], filters: { domain: options[:domain], san_contains: options[:san_contains], serial: options[:serial] }) do
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
  end

  private
  def execute_with_aws_errors(command:, profile:, region:, output:, filters: {})
    yield
  rescue ArgumentError => e
    message = if e.message =~ /Cached SSO Token is expired/i
      "AWS SSO token expired for profile #{profile}. Run: aws sso login --profile #{profile}"
    else
      e.message
    end
    render_response(output: output, command: command, resource: nil, profile: profile, region: region, filters: filters, items: [], errors: [message])
  rescue Aws::Errors::MissingCredentialsError => e
    message = "Missing AWS credentials for profile #{profile}. Set AWS_PROFILE or run: aws configure sso --profile #{profile}"
    render_response(output: output, command: command, resource: nil, profile: profile, region: region, filters: filters, items: [], errors: [message])
  rescue StandardError => e
    render_response(output: output, command: command, resource: nil, profile: profile, region: region, filters: filters, items: [], errors: [e.class.name + ': ' + e.message])
  end
end

MyCLI.start(ARGV)
