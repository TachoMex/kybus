# frozen_string_literal: true

require_relative 'base_command'

module Kybus
  module SSL
    module CLI
      DEFAULT_EXPIRATION = 5
      ROOT_CA_EXPIRATION = 20
      SUB_CA_EXPIRATION = 10
      ROOT_CA_SERIAL = 1
      SERVERS_CA_SERIAL = 2
      CLIENTS_CA_SERIAL = 3
      ROOT_CA_KEY_SIZE = 4096
      SUB_CA_KEY_SIZE = 2048
      SERVERS_CA_EXPIRATION = 5

      class Init < BaseCommand
        def build_default_config
          @template = {
            serial_counter: 3,
            certificate_descriptions: {
              defaults: certificate_defaults,
              authorities: default_authorities,
              clients: default_clients_config,
              servers: default_servers_config
            }
          }
        end

        def default_certificate_extensions
          {
            subjectKeyIdentifier: extension_details('hash'),
            authorityKeyIdentifier: extension_details('keyid:always'),
            basicConstraints: extension_details('CA:false')
          }
        end

        def extension_details(details, critical: false)
          { details:, critical: }
        end

        def certificate_defaults
          {
            saving_directory: @opts[:path],
            country: @opts[:country],
            state: @opts[:state],
            city: @opts[:city],
            organization: @opts[:organization],
            team: @opts[:team],
            key_size: @opts[:key_size],
            expiration: DEFAULT_EXPIRATION,
            extensions: default_certificate_extensions
          }
        end

        def root_ca
          ca_config("#{@opts[:organization]} Root CA", ROOT_CA_EXPIRATION, ROOT_CA_SERIAL, ROOT_CA_KEY_SIZE, 'root',
                    'root')
        end

        def servers_ca
          sub_ca_config("#{@opts[:organization]} Servers CA", SERVERS_CA_EXPIRATION, SERVERS_CA_SERIAL, 'servers')
        end

        def clients_ca
          sub_ca_config("#{@opts[:organization]} Clients CA", SUB_CA_EXPIRATION, CLIENTS_CA_SERIAL, 'clients')
        end

        def ca_config(name, expiration, serial, key_size, ca, parent, extensions: {}) # rubocop: disable Metrics/ParameterLists:
          { name:, expiration:, serial:, key_size:, ca:, parent:, extensions: }
        end

        def sub_ca_config(name, expiration, serial, ca)
          ca_config(name, expiration, serial, SUB_CA_KEY_SIZE, ca, 'root', extensions: {
                      basicConstraints: extension_details('CA:true, pathlen:0', critical: true)
                    })
        end

        def default_authorities
          {
            defaults: {
              parent: 'root',
              extensions: {
                basicConstraints: extension_details('CA:true', critical: true),
                keyUsage: extension_details('Digital Signature, keyCertSign, cRLSign', critical: true)
              }
            },
            certificates: [root_ca, servers_ca, clients_ca]
          }
        end

        def default_config(parent, extensions, extra_defaults = {})
          {
            defaults: {
              parent:,
              extensions:
            }.merge(extra_defaults),
            certificates: []
          }
        end

        def default_servers_config
          extensions = {
            'Netscape Cert Type': extension_details('SSL Server'),
            'Netscape Comment': extension_details('Server certificate'),
            keyUsage: extension_details('Digital Signature, Key Encipherment', critical: true),
            extendedKeyUsage: extension_details('TLS Web Server Authentication'),
            authorityKeyIdentifier: extension_details('keyid, issuer:always'),
            subjectAltName: extension_details('$dns')
          }
          default_config('servers', extensions)
        end

        def default_clients_config
          extensions = {
            'Netscape Cert Type': extension_details('SSL Client, S/MIME'),
            'Netscape Comment': extension_details('Client certificate'),
            keyUsage: extension_details('Digital Signature, Non Repudiation, Key Encipherment', critical: true),
            extendedKeyUsage: extension_details('TLS Web Client Authentication, E-mail Protection'),
            subjectAltName: extension_details('$email')
          }
          default_config('clients', extensions, team: @opts[:team])
        end

        def run
          abort 'File already exists. Use --force to overwrite.' if pki_file_exist? && !@opts[:force]
          build_default_config
          FileUtils.mkdir_p(@opts[:path])
          save_template
        end
      end
    end
  end
end
