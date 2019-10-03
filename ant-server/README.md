# Ant Server

The inspiration of this gem comes from 2 problems I found while developing
REST services with grape and sinatra. The first one is the following:

How do you pack the data you are sending in the answer? What happens if more
than one developer touches the service and each one uses its own way,
for example:

```
GET /api/users
{
  "status": "ok",
  "data": [
    {...}
  ]
}

GET /api/reservations
{
  "ok": true,
  "reservations": [
    {...}
  ]
}
```

As you can see, if it is not communicated, the consistency can get broken very
easily.

This was fixed by implementing a specification known as [JSend](https://github.com/omniti-labs/jsend), which is pretty
straight forward. This gem places all the endpoints under this schema removing
this problem from the development.

The second problem is how to handle errors inside the code of an API. I found
myself writing most of the code inside a "begin/rescue" block and mostly doing
the same stuff when something rescuing an exception. For example:

```ruby
get '/api/users' do
  do_cool_stuff(params)
rescue StandardError => ex
  puts "Something crashed inside app"
  puts ex.message
  puts ex.class_name
  puts ex.trace
end
```

With this, you don't need to catch those problems because the gem helps you to
handle them and keep track of what happened.

## Custom Exceptions

## Using with grape

It exposes a decorator that can be included only in the routes definition that
it is going to be used or in the main API class if it is going to be used globally.

## Using without the decorator
