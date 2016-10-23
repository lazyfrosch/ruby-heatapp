[![Build Status](https://travis-ci.org/lazyfrosch/ruby-heatapp.svg?branch=master)](https://travis-ci.org/lazyfrosch/ruby-heatapp)

Heatapp API for Ruby
====================

[Heatapp](https://heatapp.de) is a system to control your heating system at home.

It can control radiators and floor heating, measuring room temperature, and working on a defined schedule and choosen
temperatures. 

The module is still under heavy development!

I want to make it easy to access environment data.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'heatapp'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install heatapp

## Usage

Here is a basic usage example in a script:

```ruby
#!/usr/bin/env ruby

require 'bundler/setup'
require 'heatapp/api'
require 'heatapp/session'

file = 'store.yaml'
session = Heatapp::Session.new
session.load(file) if File.exist?(file)

api = Heatapp::Api.new('heatapp.localdomain', session: session)

api.login('username', 'Passw0rd') unless api.logged_in?

api.post_authenticated(path: '/api/systemstate', payload: { product: 'heatapp-server'}) do |response|
  puts response.code
  puts response.body
end

session.save(file)
```

## Interesting API targets

Here are a few interesting API targets to play with.

* `/api/systemstate`
* `/api/weather`
* `/api/room/list`
* `/api/scene/status`
* `/api/user/list`
* `/api/user/datetime`

For a full list, including POST parameter examples, see my anonymized examples in [spec/fixtures/](spec/fixtures/<url>).

* `<path>.json` is the result of an request
* `<path>.post` contains the POST data (uriencoded), excluding session parameters which would be added by `Heatapp::Api`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/lazyfrosch/ruby-heatapp.

This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to
the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

**NOTE**: This module is not affiliated with the vendor of the hardware, it's an open source module to talk to the
vendor's embedded API.

[heatapp!](https://heatapp.de) is a registered trademark of EbV Elektronikbau- und Vertriebs-GmbH -
[E-Mail](mailto:info@heatapp.de) - [Website](http://ebv-gmbh.eu).

    Copyright (C) 2016  Markus Frosch <markus@lazyfrosch.de>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
