require 'aws-sdk-acm'
require 'json'

def search_acm(profile:, region:, domain: nil, san_contains: nil, serial: nil, verbose:false, output:'text')
  client = Aws::ACM::Client.new(profile: profile, region: region)

  summaries = client.list_certificates.certificate_summary_list
  matches = []

  summaries.each do |s|
    begin
      cert = client.describe_certificate(certificate_arn: s.certificate_arn).certificate
    rescue Aws::ACM::Errors::ResourceNotFoundException
      next
    end

    ok = false
    ok ||= (domain && cert.domain_name == domain)
    ok ||= (san_contains && cert.subject_alternative_names&.any? { |n| n.include?(san_contains) })
    ok ||= (serial && cert.serial && cert.serial.casecmp(serial).zero?)

    next unless ok

    matches << {
      arn: cert.certificate_arn,
      domain_name: cert.domain_name,
      status: cert.status,
      not_before: cert.not_before,
      not_after: cert.not_after,
      issuer: cert.issuer,
      serial: cert.serial,
      in_use_by: cert.in_use_by,
      san: cert.subject_alternative_names
    }
  end

  if output == 'json'
    puts JSON.pretty_generate(matches)
  else
    if matches.empty?
      puts "No certificates found."
    else
      matches.each do |c|
        puts "ACM #{c[:arn]} domain=#{c[:domain_name]} status=#{c[:status]} "\
             "valid=#{c[:not_before]}..#{c[:not_after]} serial=#{c[:serial]}"
        if verbose
          puts "  SANs: #{Array(c[:san]).join(', ')}"
          puts "  InUseBy: #{Array(c[:in_use_by]).join(', ')}"
        end
      end
    end
  end
end


