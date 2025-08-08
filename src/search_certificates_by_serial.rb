require 'aws-sdk'

def search_certificates(domain_name)
  acm_client = Aws::ACM::Client.new(profile: 'bg-prod', region: 'us-east-1') # Cambia la región según tus necesidades
  resp = acm_client.list_certificates

  certificates = []
  resp.certificate_summary_list.each do |certificate|
    if certificate.domain_name == domain_name
      certificates << certificate
    end
  end

  return certificates
end
require 'aws-sdk-acm'

def get_certificate(certificate_arn)
  acm_client = Aws::ACM::Client.new(profile: 'bg-prod', region: 'us-east-1') # Cambia la región según tus necesidades
  resp = acm_client.describe_certificate({
    certificate_arn: certificate_arn
  })

  return resp.certificate
end

# Ejemplo de uso: busca todos los certificados con el dominio "example.com"
certificates = search_certificates('boatsgroupwebsites.com')

# Imprime los certificados encontrados
certificates.each do |certificate|
  # Ejemplo de uso: obtiene el certificado con el ARN especificado
#   puts "ARN: #{certificate.certificate_arn}"
  pp certificate
  break
  unless certificate.domain_name == "boatsgroupwebsites.com"
    pp "skipped"
    next
  end

  certificate_description = get_certificate(certificate.certificate_arn)
  certificate_description.subject_alternative_names.each do |alternative_name|
    if alternative_name == 'weaverboatworks.com'
      puts "yes --> ARN: #{certificate.certificate_arn}"
      pp certificate_description.serial
    end
  end
end
