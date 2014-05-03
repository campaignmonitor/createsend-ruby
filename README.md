# createsend

A Ruby library which implements the complete functionality of the [Campaign Monitor API](http://www.campaignmonitor.com/api/). Requires Ruby >= 1.9.3.

## Quick start

Add the gem to your `Gemfile`:

```ruby
gem 'createsend'
```

Or, install the gem:

```
gem install createsend
```

## Authenticating

The Campaign Monitor API supports authentication using either OAuth or an API key.

### Using OAuth

If you're developing a Rails or Rack based application, we recommend using [omniauth-createsend](https://github.com/jdennes/omniauth-createsend) to authenticate with the Campaign Monitor API. You might find this [example application](https://github.com/jdennes/createsendoauthtest) helpful.

If you don't use [omniauth-createsend](https://github.com/jdennes/omniauth-createsend), you'll need to get access tokens for your users by following the instructions included in the Campaign Monitor API [documentation](http://www.campaignmonitor.com/api/getting-started/#authenticating_with_oauth). This gem provides functionality to help you do this, as described below. There's also another [example application](https://gist.github.com/jdennes/4945412) you may wish to reference, which doesn't depend on any OAuth libraries.

#### Redirecting to the authorization URL

The first thing your application should do is redirect your user to the Campaign Monitor authorization URL where they will have the opportunity to approve your application to access their Campaign Monitor account. You can get this authorization URL by using `CreateSend::CreateSend.authorize_url`, like so:

```ruby
require 'createsend'

authorize_url = CreateSend::CreateSend.authorize_url(
  'Client ID for your application',
  'Redirect URI for your application',
  'The permission level your application requires',
  'Optional state data to be included'
)
# Redirect your users to authorize_url.
```

#### Exchanging an OAuth code for an access token

If your user approves your application, they will then be redirected to the `redirect_uri` you specified, which will include a `code` parameter, and optionally a `state` parameter in the query string. Your application should implement a handler which can exchange the code passed to it for an access token, using `CreateSend::CreateSend.exchange_token` like so:

```ruby
require 'createsend'

access_token, expires_in, refresh_token = CreateSend::CreateSend.exchange_token(
  'Client ID for your application',
  'Client Secret for your application',
  'Redirect URI for your application',
  'A unique code for your user' # Get the code parameter from the query string
)
# Save access_token, expires_in, and refresh_token.
```

At this point you have an access token and refresh token for your user which you should store somewhere convenient so that your application can look up these values when your user wants to make future Campaign Monitor API calls.

#### Making API calls using an access token

Once you have an access token and refresh token for your user, you can use the `createsend` gem to authenticate and make further API calls like so:

```ruby
require 'createsend'

auth = {
  :access_token => 'your access token',
  :refresh_token => 'your refresh token'
}
cs = CreateSend::CreateSend.new auth
clients = cs.clients
```

#### Refreshing access tokens

All OAuth access tokens have an expiry time, and can be renewed with a refresh token. If your access token expires when attempting to make an API call, the `CreateSend::ExpiredOAuthToken` exception will be raised, so your code should handle this. You can handle this using either `CreateSend::CreateSend.refresh_access_token` (when calling class methods) or `CreateSend::CreateSend#refresh_token` (when calling instance methods).

Here's an example of using `CreateSend::CreateSend#refresh_token` to refresh your current access token when calling `CreateSend::CreateSend#clients`:

```ruby
require 'createsend'

auth = {
  :access_token => 'your access token',
  :refresh_token => 'your refresh token'
}
cs = CreateSend::CreateSend.new auth

begin
  tries ||= 2
  clients = cs.clients
  rescue CreateSend::ExpiredOAuthToken => eot
    access_token, expires_in, refresh_token = cs.refresh_token
    # Here you should save your updated access token, 'expire in' value,
    # and refresh token. `cs` will automatically have the new access token
    # set, so there is no need to set it again.
    retry unless (tries -= 1).zero?
    p "Error: #{eot}"
  rescue Exception => e
    p "Error: #{e}"
end
```

In addition to raising `CreateSend::ExpiredOAuthToken` when an access token has expired, this library also raises `CreateSend::InvalidOAuthToken` if an invalid access token is used, and raises `CreateSend::RevokedOAuthToken` if a user has revoked the access token being used. This makes it easier for you to handle these cases in your code.

### Using an API key

```ruby
require 'createsend'

cs = CreateSend::CreateSend.new :api_key => 'your api key'
clients = cs.clients
```

## Basic usage
This example of listing all your clients and their campaigns demonstrates basic usage of the library and the data returned from the API:

```ruby
require 'createsend'

auth = {
  :access_token => 'your access token',
  :refresh_token => 'your refresh token'
}
cs = CreateSend::CreateSend.new auth

clients = cs.clients
clients.each do |cl|
  p "Client: #{cl.Name}"
  client = CreateSend::Client.new auth, cl.ClientID
  p "- Campaigns:"
  client.campaigns.each do |cm|
    p "  - #{cm.Subject}"
  end
end
```

Running this example will result in something like:

```
Client: First Client
- Campaigns:
  - Newsletter Number One
  - Newsletter Number Two
Client: Second Client
- Campaigns:
  - News for January 2013
```

## Handling errors
If the Campaign Monitor API returns an error, an exception will be raised. For example, if you attempt to create a campaign and enter empty values for subject and other required fields:

```ruby
require 'createsend'

auth = {
  :access_token => 'your access token',
  :refresh_token => 'your refresh token'
}

begin
  id = CreateSend::Campaign.create auth, "4a397ccaaa55eb4e6aa1221e1e2d7122",
    "", "", "", "", "", "", "", [], []
  p "New campaign ID: #{id}"
  rescue CreateSend::BadRequest => br
    p "Bad request error: #{br}"
    p "Error Code:    #{br.data.Code}"
    p "Error Message: #{br.data.Message}"
  rescue Exception => e
    p "Error: #{e}"
end
```

Running this example will result in:

```
Bad request error: The CreateSend API responded with the following error - 304: Campaign Subject Required
Error Code:    304
Error Message: Campaign Subject Required
```

## Expected input and output

The best way of finding out the expected input and output of a particular method in a particular class is to use the unit tests as a reference.

For example, if you wanted to find out how to call the `CreateSend::Subscriber.add` method, you would look at the file [test/subscriber_test.rb](https://github.com/campaignmonitor/createsend-ruby/blob/master/test/subscriber_test.rb)

```ruby
should "add a subscriber with custom fields" do
  stub_post(@auth, "subscribers/#{@list_id}.json", "add_subscriber.json")
  custom_fields = [ { :Key => 'website', :Value => 'http://example.com/' } ]
  email_address = CreateSend::Subscriber.add @auth, @list_id, "subscriber@example.com", "Subscriber", custom_fields, true
  email_address.should == "subscriber@example.com"
end
```

## Documentation

Ruby documentation is available at [RubyDoc.info](http://rubydoc.info/gems/createsend/frames).

## Contributing

Please check the [guidelines for contributing](https://github.com/campaignmonitor/createsend-ruby/blob/master/CONTRIBUTING.md) to this repository.

## Releasing

Please check the [instructions for releasing](https://github.com/campaignmonitor/createsend-ruby/blob/master/RELEASE.md) the `createsend` gem.

## This stuff should be green

[![Build Status](https://secure.travis-ci.org/campaignmonitor/createsend-ruby.png)][travis] [![Coverage Status](https://coveralls.io/repos/campaignmonitor/createsend-ruby/badge.png?branch=master)][coveralls] [![Dependency Status](https://gemnasium.com/campaignmonitor/createsend-ruby.png)][gemnasium] [![Gem Version](https://badge.fury.io/rb/createsend.png)][gembadge]

[travis]: http://travis-ci.org/campaignmonitor/createsend-ruby
[coveralls]: https://coveralls.io/r/campaignmonitor/createsend-ruby
[gemnasium]: https://gemnasium.com/campaignmonitor/createsend-ruby
[gembadge]: http://badge.fury.io/rb/createsend
