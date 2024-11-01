# frozen_string_literal: true

module Kybus
  module SSL
    # Stores a configuration for a certificate
    class Configuration
      ONE_YEAR = 60 * 60 * 24 * 365

      def initialize(root, group, cert)
        @config = root.merge(group).merge(cert)
      end

      def saving_directory(type)
        "#{path}/#{serial}.#{type}.pem"
      end

      def crt_path
        saving_directory('crt')
      end

      def key_path
        saving_directory('key')
      end

      def pfx_path
        "#{path}/#{serial}-#{@config['email'] || @config['name']}.pfx"
      end

      def subject_string
        "/C=#{@config['country']}/ST=#{@config['state']}" \
          "/L=#{@config['city']}/O=#{@config['organization']}" \
          "/OU=#{@config['team']}/CN=#{@config['name']}"
      end

      def configure_cert_details!(cert)
        cert.version = 2
        cert.serial = @config['serial']
        cert.subject = OpenSSL::X509::Name.parse(subject_string)
        cert.not_before = Time.now
        cert.not_after = cert.not_before + (ONE_YEAR * @config['expiration'])
      end

      def apply_placeholders(description)
        if description.include?('$')
          description.gsub('$email', "email:#{@config['email']}").gsub('$dns', "DNS:#{@config['dns']}")
        else
          description
        end
      end

      def configure_extensions!(cert, extension_factory)
        @config['extensions'].each do |name, details|
          applied_description = apply_placeholders(details['details'])
          extension = extension_factory.create_extension(
            name,
            applied_description,
            details['critical']
          )
          cert.add_extension(extension)
        end
      end

      def [](key)
        @config[key]
      end
      private

      def path
        @config['saving_directory']
      end

      def serial
        @config['serial']
      end
    end
  end
end
