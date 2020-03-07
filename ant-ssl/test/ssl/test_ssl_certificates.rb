# frozen_string_literal: true

require './test/test_helper'
require 'fileutils'

class TestSSLCertificates < Minitest::Test
  PATH = './storage/test_pki'
  SUBJECTS = [
    '',
    '/C=MX/ST=Jalisco/L=Guadalajara/O=ant-server/OU=tech/CN=Ant Root CA',
    '/C=MX/ST=Jalisco/L=Guadalajara/O=ant-server/OU=tech/CN=Ant Servers CA',
    '/C=MX/ST=Jalisco/L=Guadalajara/O=ant-server/OU=tech/CN=Ant Clients CA',
    '/C=MX/ST=Jalisco/L=Guadalajara/O=ant-server/OU=tech/CN=Tacho',
    '/C=MX/ST=Jalisco/L=Guadalajara/O=ant-server/OU=tech/CN=Tacho Banned',
    '/C=MX/ST=Jalisco/L=Guadalajara/O=ant-server/OU=tech/CN=' \
    'development.ant-server.io',
    '/C=MX/ST=Jalisco/L=Guadalajara/O=ant-server/OU=tech/CN=*.ant-server.io'
  ].freeze
  def setup
    FileUtils.rm_rf(PATH)
  end

  def assert_file(path)
    assert(File.file?(path))
  end

  def assert_certificate(path, subject)
    assert_file(path)
    certificate = OpenSSL::X509::Certificate.new(File.read(path))
    assert_equal(certificate.subject.to_s, subject)
  end

  def inventory
    conf = CONFIGS
    cert_conf = conf['certificate_descriptions']
    defaults = cert_conf['defaults']
    authorities = cert_conf['authorities']
    clients = cert_conf['clients']
    servers = cert_conf['servers']
    Ant::SSL::Inventory.new(defaults, authorities, clients, servers)
  end

  # rubocop: disable UncommunicativeMethodParamName
  def assert_parents(ca, cert)
    ca_path = "#{PATH}/#{ca}.crt.pem"
    cert_path = "#{PATH}/#{cert}.crt.pem"
    string = `openssl verify -verbose -CAfile #{ca_path}  #{cert_path}`
    assert_equal(string, "#{cert_path}: OK\n")
  end
  # rubocop: enable UncommunicativeMethodParamName

  def assert_certificate_parents
    `cd storage/test_pki; cat 1.crt.pem 2.crt.pem > 2_chain.crt.pem`
    `cd storage/test_pki; cat 1.crt.pem 3.crt.pem > 3_chain.crt.pem`
    assert_parents('1', '2')
    assert_parents('1', '3')
    assert_parents('3_chain', '4')
    assert_parents('3_chain', '5')
    assert_parents('2_chain', '6')
    assert_parents('2_chain', '7')
  end

  def test_pki_generation
    inv = inventory
    inv.create_certificates!
    (1..7).each do |serial|
      assert_file("#{PATH}/#{serial}.key.pem")
      assert_certificate("#{PATH}/#{serial}.crt.pem", SUBJECTS[serial])
    end
    assert_certificate_parents
  end
end
