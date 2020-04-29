# frozen_string_literal: true

require_relative '../lib/kybus/ssl'
require 'yaml'

conf = YAML.load_file('./config/certificates_theetntropylabs.yaml')
cert_conf = conf['certificate_descriptions']
defaults = cert_conf['defaults']
authorities = cert_conf['authorities']
clients = cert_conf['clients']
servers = cert_conf['servers']
inv = Kybus::SSL::Inventory.new(defaults, authorities, clients, servers)

inv.create_certificates!
