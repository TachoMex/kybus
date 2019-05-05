# frozen_string_literal: true

require 'simplecov'
require 'minitest/test'
require 'minitest/autorun'
require 'rdoc'
require 'mocha/minitest'

SimpleCov.minimum_coverage 100
SimpleCov.start

class TestGenerateDocs < Minitest::Test
  DOC_COVERAGE = 17
  def test_run
    doc = RDoc::RDoc.new
    doc.document ['lib']

    covered = doc.stats.percent_doc

    return if covered >= DOC_COVERAGE

    puts "Doc Coverage #{covered}%/#{DOC_COVERAGE}% was not covered."
    raise('LowCoverageError')
  end
end

CONFIGS = {
  'certificate_descriptions' => {
    'defaults' => {
      'saving_directory' => './storage/test_pki/',
      'country' => 'MX',
      'state' => 'Jalisco',
      'city' => 'Guadalajara',
      'organization' => 'ant-server',
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
          'name' => 'Ant Root CA',
          'expiration' => 20,
          'serial' => 1,
          'key_size' => 4096,
          'ca' => 'root',
          'parent' => 'root'
        },
        {
          'name' => 'Ant Servers CA',
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
          'name' => 'Ant Clients CA',
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
          }
        }
      },
      'certificates' => [
        {
          'name' => 'Tacho',
          'email' => 'tachoguitar@gmail.com',
          'serial' => 4
        },
        {
          'name' => 'Tacho Banned',
          'email' => 'tachoguitar@gmail.com',
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
          }
        }
      },
      'certificates' => [
        {
          'name' => 'development.ant-server.io',
          'ip' => '127.0.0.1',
          'serial' => 6
        },
        {
          'name' => '*.ant-server.io',
          'serial' => 7
        }
      ]
    }
  }
}.freeze

require 'ant/ssl'
