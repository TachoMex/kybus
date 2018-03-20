# Ruby Ants Framework

Ruby ants aims to be a framework for building microservices-based
applications. Also, we expect that this framework will be very flexible so
it will be possible to use small components without loading all the features.

You can have:
- Some cool stuff for general purposes.
  - Resource injection module.
  - A basic and very general daemon.
- HTTP client powered by HTTParty, but trying to be object based so you can easily manage session, parsing, cookies, auth, etc.
- HTTP servers with either sinatra or grape.
  - One problem I often found is the consistency while writing rest services. This allows you to have all the same look in all the endpoints by implementing a JSend specification.
  - Log all the request on a basic way. Log an access log when a successful request was performed. Log a message when the client made a mistake. Log a full detail stack trace and params when the api crashes.
  - But if you don't like anything you should be capable of modifying it and use it the way you prefer.
- Want to use kafka or a distribuited queue service to build pipelines? you can have daemons listening to queues and processing the messages.
- Do you have a system that is so trivial that it would be a waste to write? We introduce *nanoservices*. This will give a shipping-ready API with CRUD operations (the ones you need), connected to a database via sequel. All this can be done using a yaml file describing the data models.

This is not yet finished and is very likely that you can not find something yet,
but we are working to have an amazing framework that we can rely on.
