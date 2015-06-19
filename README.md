# Keboola GoodData Writer API Ruby client

[![Quality](http://img.shields.io/codeclimate/github/romansklenar/gooddata-writer-ruby-client.svg?style=flat-square)](https://codeclimate.com/github/romansklenar/gooddata-writer-ruby-client)
[![Coverage](http://img.shields.io/codeclimate/coverage/github/romansklenar/gooddata-writer-ruby-client.svg?style=flat-square)](https://codeclimate.com/github/romansklenar/gooddata-writer-ruby-client)
[![Build](http://img.shields.io/travis-ci/romansklenar/gooddata-writer-ruby-client.svg?style=flat-square)](https://travis-ci.org/romansklenar/gooddata-writer-ruby-client)
[![Dependencies](http://img.shields.io/gemnasium/romansklenar/gooddata-writer-ruby-client.svg?style=flat-square)](https://gemnasium.com/romansklenar/gooddata-writer-ruby-client)
[![Downloads](http://img.shields.io/gem/dtv/gooddata-writer-ruby-client.svg?style=flat-square)](https://rubygems.org/gems/gooddata-writer-ruby-client)
[![Tags](http://img.shields.io/github/tag/romansklenar/gooddata-writer-ruby-client.svg?style=flat-square)](http://github.com/romansklenar/gooddata-writer-ruby-client/tags)
[![Releases](http://img.shields.io/github/release/romansklenar/gooddata-writer-ruby-client.svg?style=flat-square)](http://github.com/romansklenar/gooddata-writer-ruby-client/releases)
[![Issues](http://img.shields.io/github/issues/romansklenar/gooddata-writer-ruby-client.svg?style=flat-square)](http://github.com/romansklenar/gooddata-writer-ruby-client/issues)
[![License](http://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat-square)](http://opensource.org/licenses/MIT)
[![Version](http://img.shields.io/gem/v/gooddata-writer-ruby-client.svg?style=flat-square)](https://rubygems.org/gems/gooddata-writer-ruby-client)


Simple Ruby wrapper library for [Keboola GoodData Writer REST API](http://docs.keboolagooddatawriter.apiary.io/).


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'keboola-gooddata-writer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install keboola-gooddata-writer

## Usage

Obtain your Keboola Storage API token and use to initialize client.

```ruby
api = Keboola::GoodDataWriter::API.new(token: '123-abcdefghjklmnopqrstuvxyz')

# get details of specific writer
api.writer('MyWriter') # {"bucket"=>"sys.c-wr-gooddata-writer1", "writer"=>"gooddata", "writerId"=>"writer1", …, "status"=>"ready"}

# create GoodData project
api.create_project('MyWriter', optionals: { name: 'KBC - MyProject - MyWriter' }) # <Keboola::GoodDataWriter::Job url="https://syrup.keboola.com/queue/jobs/123456", id="123456">

# create user
api.create_user('MyWriter', 'john.snow@test.keboola.com', 't0pS3cr3t', 'John', 'Snow') # <Keboola::GoodDataWriter::Job url="https://syrup.keboola.com/queue/jobs/123456", id="123456">

# assign user to existing GoodData project
api.add_project_users('MyWriter', 'xjywplmhejceb6j3ezzlxiganmjavqio', 'john.snow@test.keboola.com', 'editor') #<Keboola::GoodDataWriter::Job url="https://syrup.keboola.com/queue/jobs/123456", id="123456">

# getretreive GoodData SSO link
api.sso('MyWriter', 'xjywplmhejceb6j3ezzlxiganmjavqio', 'john.snow@test.keboola.com') # "https://secure.gooddata.com/gdc/account/customerlogin?sessionId=-----BEGIN+PGP+MESSAGE-----s0m3_l0000n6_h4sh"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

Tests are runned against [mock API server](https://private-anon-cf7bb7f95-keboolagooddatawriter.apiary-mock.com). If you want to run tests against production API server you must provide valid Keboola Storage API token and set it as environment variable called `KEBOOLA_STORAGE_API_TOKEN`.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing
Get familiar with [Github Flow](https://guides.github.com/introduction/flow/index.html) and stick with it on this project.
We're using [Github Issues](https://github.com/slowpath/rails-insights/issues) as an issue tracker. All related tasks are there.

It's simple!
  1. Fork it ( https://github.com/romansklenar/keboola-gooddata-writer/fork )
  2. Create your feature branch (`git checkout -b my-new-feature`)
  3. Commit your changes (`git commit -am 'Add some feature'`)
  4. Push to the branch (`git push origin my-new-feature`)
  5. Create a new Pull Request
