# Ruby Kybus Framework [![Build Status](https://travis-ci.com/TachoMex/kybus.svg?token=mByHJndryoQGoBVujqw2&branch=develop)](https://travis-ci.com/TachoMex/kybus)

Kybus provides a series of little gems that will help you to solve small problems.
This gem was inspired by boiler plate code that I was failing on repeating each
time I started a new project. The idea of this project is to provide tools for
making apps that are microservices-oriented.

This repository contains one folder for each gem and an integration app, which
will serve as an example of how I think this could be integrated. Each gem
must have a 100% coverage in unit testing, and also the integration app should
get fully tested along with the gems.

Docker will be added so it can have databases in integration tests and allowing
to run tests just by cloning the repository.

## Gems
Check the readme files for each gem so you can get more details about what each
gem does. Here is a brief description of the general idea for each gem.

### Bot
ChatBots are getting common nowadays and there are many providers. They work on
a similar way: a message poll using a websocket, each time a message is received
you get access to the message contents and the sender data. This aims to provide
an adapter model that will make it easier to change from slack to telegram by
modifying some configurations (similar to sequel).

### Client
A library for creating HTTP clients powered by HTTParty.

### Configs
A library for loading configurations. It will provide many distinct sources to
make it easier for you to handle them.

### Core
Provides common implementations for the gems, like a dependency injection
mechanism.

### Logger
Provides an easy way for handling logs and metrics.

### Nanoservice
This is not a stable gem yet. It is an experiment for making an API from a
configuration that describes the data types and the restrictions and expose it
using a REST service.

### Pipeline
Using a queue as a message processing mechanism, it allows to create a service
that will consume a queue and execute tasks from them.

### Server
For REST services powered by frameworks like sinatra or grape, it will provide
some methods for stardardizing the api calls, logs and error handling.

### SSL
If you need to create a PKI for development purposes, this helps you to build
them without the need of understanding how openssl works.

### Storage
If you need to store data and use some desing patterns like factory or repository,
this gem helps you to build your ORM and DAO easier.
