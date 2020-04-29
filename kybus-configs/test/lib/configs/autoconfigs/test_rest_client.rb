# frozen_string_literal: true

require_relative 'autoconfig_test'

class TestRestClient < AutoconfigTest
  def test_rest_client
    conf = YAML.load_file('./config/rest_client.yaml')
    conf = build_config(conf)

    response = { token: 'SignedToken', result: 'success' }

    stub_request(:post, 'https://google.com/hello')
      .with(body: '{"user":"test","pass":"1234"}')
      .to_return(status: 200,
                 body: { status: :success, data: response }.to_json)
    client = conf.services('rest_client', 'google')
    login = client.post('/hello', user: 'test', pass: '1234')
    assert_equal(login[:status], 'success')
    assert_equal(login[:data], response)
  end
end
