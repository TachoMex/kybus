# Kybus Bot
===
This package allows you to create chat bots compatible with telegram and discord.

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
    'token' => 'TOKEN'
    }
  }
}.freeze

Kybus::Bot::Migrator.run_migrations!(Sequel.connect(conf['state_repository']['endpoint']))

bot = Kybus::Bot::Base.new(conf)

bot.register_command('/hello') do
  send_message("hello human")
end

bot.run
```
