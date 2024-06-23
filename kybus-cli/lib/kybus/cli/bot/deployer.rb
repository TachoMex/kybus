require 'net/http'
require 'uri'
require 'json'
require 'rake'
require 'securerandom'
require 'fileutils'
require 'yaml'
require 'aws-sdk-iam'
require 'aws-sdk-lambda'
require 'aws-sdk-cloudwatchlogs'
require 'zip'

class Deployer
  def initialize(options)
    @params = options
  end

  def function_name
    "#{@params[:env] || 'production'}-#{@config['name']}"
  end

  def compress_repo!
    require 'zip'
    FileUtils.rm(@output_path, force: true)
    entries = Dir.entries(@repo_path) - %w[. ..]

    zipfile_name = @output_path

    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
      entries.each do |entry|
        entry_path = File.join(@repo_path, entry)
        if File.directory?(entry_path)
          zipfile.mkdir(entry)
          Dir[File.join(entry_path, '**', '**')].each do |file|
            zipfile.add(file.sub(@repo_path + '/', ''), file)
          end
        else
          zipfile.add(entry, entry_path)
        end
      end
    end
  end

  def account_id
    @account_id ||= begin
      sts_client = Aws::STS::Client.new
      response = sts_client.get_caller_identity
      response.account
    end
  end

  def create_policy!(name, body)
    @iam_client.create_policy(policy_name: name, policy_document: body.to_json)
    puts "Policy '#{name}' created."
  rescue Aws::IAM::Errors::EntityAlreadyExists
    puts "Policy '#{name}' already exists."
  end

  def attach_policy!(name, role)
    @iam_client.attach_role_policy(role_name:  role, policy_arn: "arn:aws:iam::#{account_id}:policy/#{name}")
    puts "Policy '#{name}' attached to role '#{role}'."
  rescue Aws::IAM::Errors::EntityAlreadyExists
    puts "Policy '#{name}' already attached to role '#{role}'."
  end

  def create_roles!
    @iam_client = Aws::IAM::Client.new
    policy_name = "#{function_name}-execution_policy"
    role_name = "#{function_name}-execution_role"
    dynamo_policy_name = "#{function_name}-dynamo_policy"

    create_policy!(policy_name,
                   Version: '2012-10-17',
                   Statement: [
                     {
                       Effect: 'Allow',
                       Action: 'logs:CreateLogGroup',
                       Resource: "arn:aws:logs:#{@region}:#{account_id}:*"
                     },
                     {
                       Effect: 'Allow',
                       Action: [
                         'logs:CreateLogStream',
                         'logs:PutLogEvents'
                       ],
                       Resource: [
                         "arn:aws:logs:#{@region}:#{account_id}:log-group:/aws/lambda/#{function_name}:*"
                       ]
                     }
                   ])

    create_policy!(dynamo_policy_name, {
                     Version: '2012-10-17',
                     Statement: [
                       {
                         Effect: 'Allow',
                         Action: [
                           'dynamodb:BatchGetItem',
                           'dynamodb:BatchWriteItem',
                           'dynamodb:Describe*',
                           'dynamodb:Get*',
                           'dynamodb:List*',
                           'dynamodb:PutItem',
                           'dynamodb:Query',
                           'dynamodb:Scan',
                           'dynamodb:UpdateItem',
                           'dynamodb:DeleteItem'
                         ],
                         Resource: "arn:aws:dynamodb:#{@region}:#{account_id}:table/#{function_name}*"
                       }, {
                         Effect: :Allow,
                         Action: [
                           'dynamodb:Describe*',
                           'dynamodb:Get*',
                           'dynamodb:List*'
                         ],
                         Resource: '*'
                       }
                     ]
                   })
    assume_role_policy_document = {
      Version: '2012-10-17',
      Statement: [
        {
          Effect: 'Allow',
          Principal: {
            Service: 'lambda.amazonaws.com'
          },
          Action: 'sts:AssumeRole'
        }
      ]
    }.to_json

    begin
      @iam_client.create_role({
                                role_name:,
                                assume_role_policy_document:
                              })
      puts "Role '#{role_name}' created."
    rescue Aws::IAM::Errors::EntityAlreadyExists
      puts "Role '#{role_name}' already exists."
    end

    attach_policy!(policy_name, role_name)
    attach_policy!(dynamo_policy_name, role_name)
  end

  def with_retries(max_retries = 5)
    retry_count = 0
    begin
      yield
    rescue Aws::Lambda::Errors::ResourceConflictException => e
      retry_count += 1
      unless retry_count <= max_retries
        raise "Failed to deploy Lambda function after #{max_retries} attempts due to ongoing updates."
      end

      sleep_time = 2**retry_count
      puts "Update in progress, retrying in #{sleep_time} seconds..."
      sleep(sleep_time)
      retry
    end
  end

  def create_log_group!
    logs_client = Aws::CloudWatchLogs::Client.new(region: @region)
    log_group_name = "/aws/lambda/#{function_name}"

    begin
      logs_client.create_log_group(log_group_name:)
      puts "Log group '#{log_group_name}' created."
    rescue Aws::CloudWatchLogs::Errors::ResourceAlreadyExistsException
      puts "Log group '#{log_group_name}' already exists."
    end
  end

  def make_public!
    lambda_client = Aws::Lambda::Client.new(region: @region)

    begin
      response = lambda_client.add_permission({
                                                function_name:,
                                                statement_id: 'AllowPublicInvoke',
                                                action: 'lambda:InvokeFunctionUrl',
                                                principal: '*',
                                                function_url_auth_type: 'NONE'
                                              })
      puts "Permission added successfully: #{response}"
    rescue Aws::Lambda::Errors::ServiceError => e
      puts "Error adding permission: #{e.message}"
    end
  end

  def deploy_lambda!
    create_roles!
    create_log_group!

    lambda_client = Aws::Lambda::Client.new
    function_exists = begin
      lambda_client.get_function(function_name:)
    rescue StandardError
      false
    end

    if function_exists
      with_retries do
        lambda_client.update_function_code(function_name:, zip_file: File.read(@output_path))
      end

      with_retries do
        lambda_client.update_function_configuration({
                                                      function_name:,
                                                      environment: {
                                                        variables: {
                                                          'SECRET_TOKEN' => @config['secret_token']
                                                        }
                                                      }
                                                    })
      end
      puts "Lambda function '#{function_name}' updated."
    else
      with_retries do
        lambda_client.create_function({
                                        function_name:,
                                        runtime: 'ruby3.3',
                                        role: "arn:aws:iam::#{account_id}:role/#{function_name}-execution_role",
                                        handler: 'handler.lambda_handler',
                                        code: {
                                          zip_file: File.read(@output_path)
                                        },
                                        environment: {
                                          variables: {
                                            'SECRET_TOKEN' => @config['secret_token']
                                          }
                                        }
                                      })
        puts "Lambda function '#{function_name}' created."
      end
    end

    with_retries do
      response = lambda_client.create_function_url_config({
                                                            function_name:,
                                                            auth_type: 'NONE'
                                                          })
      puts "Function URL created: #{response.function_url}"
      @url = response.function_url
    rescue Aws::Lambda::Errors::ResourceConflictException
      response = lambda_client.get_function_url_config({
                                                         function_name:
                                                       })
      puts "Function URL exists: #{response.function_url}"
      @url = response.function_url
    end

    make_public!
  end

  def run_migrations!
    Rake::Task.clear
    load 'Rakefile'
    Rake::Task['db:migrate'].invoke
  end

  def set_webhook!
    raise 'Missing Token' if @config['secret_token'].nil?

    uri = URI("https://api.telegram.org/bot#{@config['bot_token']}/setWebhook")
    params = { url: @url, secret_token: @config['secret_token'] }
    res = Net::HTTP.post_form(uri, params)
    puts res.body
  end

  def load_kybusdeploy_file!
    @config = YAML.load_file('./kybusbot.yaml')
    @repo_path = '.'
    @output_path = './.kybusbotcode.zip'
    @region = @config['region'] || 'us-east-1'
  end

  def run
    load_kybusdeploy_file!
    compress_repo!
    deploy_lambda!
    set_webhook!
  end
end
