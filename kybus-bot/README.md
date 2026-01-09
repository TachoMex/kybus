# Kybus Bot
This package allows you to create chat bots compatible with Telegram and Discord.

## Quick Start
The minimum needed setup is the following:

```ruby
require 'kybus/bot'

conf = {
  'name' => 'testbot',
  'state_repository' => {
    'name' => 'sequel',
    'endpoint' => 'sqlite://storage/kybus-bot.db'
  },
  'pool_size' => 1,
  'provider' => {
    'name' => 'telegram',
    'token' => 'TOKEN',
    'parse_mode' => 'MarkdownV2'
  }
}.freeze

Kybus::Bot::Migrator.run_migrations!(conf['state_repository'])

bot = Kybus::Bot::Base.new(conf)

bot.register_command('/hello') do
  send_message("hello human")
end

bot.run
```

## Command Help (Auto Hints)
Enable automatic help injection and hints:

```ruby
Kybus::Bot::Base.enable_command_help!

bot.register_command('/hello', hint: 'Says hello') do
  send_message('hello human')
end
```

This injects:
- `/help` with a list of commands and hints
- `/help_<command>` with usage details

## State Repository
Kybus Bot supports `sequel` and `dynamoid` repositories for `bot_sessions`.

### Sequel
```ruby
conf['state_repository'] = {
  'name' => 'sequel',
  'endpoint' => 'sqlite://storage/kybus-bot.db'
}
Kybus::Bot::Migrator.run_migrations!(conf['state_repository'])
```

### DynamoDB (Dynamoid)
```ruby
conf['state_repository'] = {
  'name' => 'dynamoid',
  'access_key' => 'AKIA...',
  'secret_key' => '...',
  'region' => 'us-east-1',
  'endpoint' => 'https://dynamodb.us-east-1.amazonaws.com',
  'namespace' => 'kybus',
  'read_capacity' => 1,
  'write_capacity' => 1
}
Kybus::Bot::Migrator.run_migrations!(conf['state_repository'])
```

## Forkers (Lambda + SQS)
Kybus Bot includes a Lambda SQS forker for async jobs:

```ruby
conf['forker'] = {
  'provider' => 'sqs',
  'queue' => 'MyQueue'
}
```

Then call jobs from a command:
```ruby
register_job('my_job', args: { user_id: 'string' }) do |args|
  send_message("Job for #{args[:user_id]}")
end

fork('my_job', user_id: '123')
```

## Testing
Use the built-in test helpers:
```ruby
require 'kybus/bot/test'
```
There are example test bots under `test/` that show how to:
- Instantiate a test bot
- Send fake messages
- Assert responses

### Test Examples
Basic command assertion:
```ruby
bot = Kybus::Bot::Base.make_test_bot
bot.register_command('/ping') { send_message('pong') }
bot.expects(:send_message).with('pong')
bot.receives('/ping')
```

Inline args:
```ruby
bot = Kybus::Bot::Base.make_test_bot('inline_args' => true)
bot.register_command('/hello', %i[number letter]) { confirm(params[:number], params[:letter]) }
bot.expects(:confirm).with('8', 'a')
bot.receives('/hello8__a')
```

Reply handling:
```ruby
bot.register_command('/reply') { send_message('Hello') }
bot.register_command('default') do
  if last_message.reply?
    send_message("Reply: #{last_message.raw_message}")
  end
end
bot.receives('/reply')
bot.expects(:send_message).with('Reply: World')
bot.replies('World')
```

File upload:
```ruby
bot.register_command('/file', %i[file]) do
  send_message(file(:file).download)
end
bot.receives('/file')
bot.expects(:send_message).with("hello-bot\n")
bot.receives('hello', 'file.txt')
```

Metadata:
```ruby
token = 123
bot.register_command('/set') { metadata[:token] = token }
bot.register_command('/get') { send_message(metadata[:token].to_s) }
bot.expects(:send_message).with('123')
bot.receives('/set')
bot.receives('/get')
```

Abort:
```ruby
bot.register_command('/stop') { abort('Stop execution') }
bot.expects(:send_message).with('Stop execution')
bot.receives('/stop')
```

Redirect:
```ruby
bot.register_command('/start') { redirect('/next', 5) }
bot.register_command('/next', %i[number]) { send_message("N=#{params[:number]}") }
bot.expects(:send_message).with('N=5')
bot.receives('/start')
```

## DSL Reference
Main DSL methods available inside command blocks:

| Method | Description |
| --- | --- |
| `send_message(content, channel = nil)` | Send a text message. If `channel` is nil, uses the current channel. |
| `send_image(content, channel = nil, caption: nil)` | Send an image file or URL with optional caption. |
| `send_video(content, channel = nil, caption: nil)` | Send a video file or URL with optional caption. |
| `send_audio(content, channel = nil)` | Send an audio file or URL. |
| `send_document(content, channel = nil)` | Send a document file or URL. |
| `params` | Hash of parsed command parameters. |
| `files` | Hash of uploaded files keyed by param name. |
| `metadata` | Hash of persisted state for the current channel. |
| `file(name)` | Fetch a file builder from `files`. |
| `mention(name)` | Build a mention for a user. |
| `current_user` | Returns the current user identifier from the provider. |
| `current_channel` | Returns the current channel identifier. |
| `last_message` | Returns the last message object. |
| `is_private?` | True when the message is private. |
| `command_name` | Current command name. |
| `save_metadata!` | Persist `metadata` to the state repository. |
| `redirect(command, *params)` | Redirect to another command with params. |
| `abort(msg = nil)` | Abort execution with an optional message. |
| `fork(command, arguments = {})` | Enqueue a background job with arguments. |
| `fork_with_delay(command, delay, arguments = {})` | Enqueue a background job after a delay. |

## Notes
- `parse_mode` can be set in provider config when using Telegram.
- Prefer `send_message` from DSL over direct adapter usage.
