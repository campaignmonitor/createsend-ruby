# createsend
[![Build Status](https://secure.travis-ci.org/campaignmonitor/createsend-ruby.png)][travis] [![Dependency Status](https://gemnasium.com/campaignmonitor/createsend-ruby.png)][gemnasium] [![Gem Version](https://badge.fury.io/rb/createsend.png)][gembadge]

A ruby library which implements the complete functionality of the [Campaign Monitor API](http://www.campaignmonitor.com/api/).

[travis]: http://travis-ci.org/campaignmonitor/createsend-ruby
[gemnasium]: https://gemnasium.com/campaignmonitor/createsend-ruby
[gembadge]: http://badge.fury.io/rb/createsend

## Installation

    gem install createsend

## Documentation

Full documentation is hosted by [RubyDoc.info](http://rubydoc.info/gems/createsend/frames).

## Examples

### Authenticating

The Campaign Monitor API supports authentication using either OAuth or an API key.

#### Using OAuth

We recommend using [omniauth-createsend](https://github.com/campaignmonitor/omniauth-createsend) to authenticate users of your application, then once you have an access token and refresh token for your user, authenticate with the createsend gem like so:

```ruby
require 'createsend'

CreateSend.oauth 'your_access_token_', 'your_refresh_token'
cs = CreateSend::CreateSend.new
clients = cs.clients
```

If you choose not to use [omniauth-createsend](https://github.com/campaignmonitor/omniauth-createsend), you'll need to get access tokens for your users by following the instructions included in the Campaign Monitor API [documentation](http://www.campaignmonitor.com/api/getting-started/#authenticating_with_oauth).

#### Using an API key

```ruby
require 'createsend'

CreateSend.api_key 'your_api_key'
cs = CreateSend::CreateSend.new
clients = cs.clients
```

### Basic usage
This example of listing all your clients demonstrates basic usage of the library:

```ruby
require 'createsend'

CreateSend.oauth 'your_access_token', 'your_refresh_token'

cs = CreateSend::CreateSend.new
clients = cs.clients
    
clients.each do |c|
  puts "#{c.ClientID}: #{c.Name}"
end
```

Running this example will result in something like:

```
4a397ccaaa55eb4e6aa1221e1e2d7122: Client One
a206def0582eec7dae47d937a4109cb2: Client Two
```

### Handling errors
If the Campaign Monitor API returns an error, an exception will be thrown. For example, if you attempt to create a campaign and enter empty values for subject etc:

```ruby
require 'createsend'

CreateSend.oauth 'your_access_token', 'your_refresh_token'

begin
  cl = CreateSend::Client.new "4a397ccaaa55eb4e6aa1221e1e2d7122"
  id = CreateSend::Campaign.create cl.client_id, "", "", "", "", "", "", "", [], []
  puts "New campaign ID: #{id}"
  rescue CreateSend::BadRequest => br
    puts "Bad request error: #{br}"
    puts "Error Code:    #{br.data.Code}"
    puts "Error Message: #{br.data.Message}"
  rescue Exception => e
    puts "Error: #{e}"
end
```

Running this example will result in:

```
Bad request error: The CreateSend API responded with the following error - 304: Campaign Subject Required
Error Code:    304
Error Message: Campaign Subject Required
```

### Expected input and output
The best way of finding out the expected input and output of a particular method in a particular class is to use the unit tests as a reference.

For example, if you wanted to find out how to call the CreateSend::Subscriber.add method, you would look at the file test/subscriber_test.rb

```ruby
should "add a subscriber with custom fields" do
  stub_post(@api_key, "subscribers/#{@list_id}.json", "add_subscriber.json")
  custom_fields = [ { :Key => 'website', :Value => 'http://example.com/' } ]
  email_address = CreateSend::Subscriber.add @list_id, "subscriber@example.com", "Subscriber", custom_fields, true
  email_address.should == "subscriber@example.com"
end
```

## Contributing
1. Fork the repository
2. Make your changes, including tests for your changes.
3. Ensure that the build passes, by running `bundle exec rake` (CI runs on: `1.9.3`, `1.9.2`, `1.8.7` and `ree`)
4. It should go without saying, but do not increment the version number in your commits.
5. Submit a pull request.
