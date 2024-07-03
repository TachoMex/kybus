# frozen_string_literal: true

require 'simplecov'
require 'minitest/autorun'

SimpleCov.minimum_coverage 100
SimpleCov.start

CONFIGS = {
  'certificate_descriptions' => {
    'defaults' => {
      'saving_directory' => './storage/test_pki/',
      'country' => 'MX',
      'state' => 'Jalisco',
      'city' => 'Guadalajara',
      'organization' => 'kybus-server',
      'team' => 'tech',
      'key_size' => 1048,
      'expiration' => 5,
      'parent' => 'servers',
      'extensions' => {
        'subjectKeyIdentifier' => {
          'details' => 'hash',
          'critical' => false
        },
        'authorityKeyIdentifier' => {
          'details' => 'keyid:always',
          'critical' => false
        },
        'basicConstraints' => {
          'details' => 'CA:false',
          'critical' => false
        }
      }
    },
    'authorities' => {
      'defaults' => {
        'parent' => 'root',
        'extensions' => {
          'basicConstraints' => {
            'details' => 'CA:true',
            'critical' => true
          },
          'keyUsage' => {
            'details' => 'Digital Signature, keyCertSign, cRLSign',
            'critical' => true
          }
        }
      },
      'certificates' => [
        {
          'name' => 'Kybus Root CA',
          'expiration' => 20,
          'serial' => 1,
          'key_size' => 4096,
          'ca' => 'root',
          'parent' => 'root'
        },
        {
          'name' => 'Kybus Servers CA',
          'parent' => 'root',
          'expiration' => 10,
          'serial' => 2,
          'ca' => 'servers',
          'key_size' => 2048,
          'extensions' => {
            'basicConstraints' => {
              'details' => 'CA:true, pathlen:0',
              'critical' => true
            }
          }
        },
        {
          'name' => 'Kybus Clients CA',
          'parent' => 'root',
          'expiration' => 10,
          'serial' => 3,
          'ca' => 'clients',
          'key_size' => 2048,
          'extensions' => {
            'basicConstraints' => {
              'details' => 'CA:true, pathlen:0',
              'critical' => true
            }
          }
        }
      ]
    },
    'clients' => {
      'defaults' => {
        'parent' => 'clients',
        'extensions' => {
          'Netscape Cert Type' => {
            'details' => 'SSL Client, S/MIME',
            'critical' => false
          },
          'Netscape Comment' => {
            'details' => 'Client certificate',
            'critical' => false
          },
          'keyUsage' => {
            'details' => 'Digital Signature, Non Repudiation, Key Encipherment',
            'critical' => true
          },
          'extendedKeyUsage' => {
            'details' => 'TLS Web Client Authentication, E-mail Protection',
            'critical' => false
          },
          'subjectAltName' => {
            'details' => '$email',
            'critical' => false
          }

        }
      },
      'certificates' => [
        {
          'name' => 'Tacho',
          'email' => 'mail@mail.com',
          'serial' => 4
        },
        {
          'name' => 'Tacho Banned',
          'email' => 'mail@mail.com',
          'serial' => 5,
          'revoked' => true
        }
      ]
    },
    'servers' => {
      'defaults' => {
        'parent' => 'servers',
        'extensions' => {
          'Netscape Cert Type' => {
            'details' => 'SSL Server',
            'critical' => false
          },
          'Netscape Comment' => {
            'details' => 'Server certificate',
            'critical' => false
          },
          'keyUsage' => {
            'details' => 'Digital Signature, Key Encipherment',
            'critical' => true
          },
          'extendedKeyUsage' => {
            'details' => 'TLS Web Server Authentication',
            'critical' => false
          },
          'authorityKeyIdentifier' => {
            'details' => 'keyid, issuer:always',
            'critical' => false
          },
          'subjectAltName' => {
            'details' => '$dns',
            'critical' => false
          }
        }
      },
      'certificates' => [
        {
          'name' => 'development.kybus-server.io',
          'dns' => 'development.kybus-server.io',
          'ip' => '127.0.0.1',
          'serial' => 6
        },
        {
          'name' => '*.kybus-server.io',
          'dns' => '*.kybus-server.io',
          'serial' => 7
        }
      ]
    }
  }
}.freeze

require 'kybus/ssl'
