# createsend-ruby history

## v4.1.0 - 4 Aug, 2015

* Added support for Transactional Email

## v4.0.2 - 15 Oct, 2014

* Bumped and simplified `hashie` dependency to `~> 3.0`

## v4.0.1 - 3 May, 2014

* This is a patch release which only changes development dependencies.
* Removed development dependency on `shoulda` and added more suitable dependency on `shoulda-context` instead.

## v4.0.0 - 19 Feb, 2014

* Removed `CreateSend::CreateSend#apikey` to promote using OAuth rather than basic auth with an API key.
* Started using the `https://api.createsend.com/api/v3.1/` API endpoint.
* Added support for new segments structure.
  * Create and Update calls now require the new `rule_groups` structure, instead of a `rules` structure.

    ```ruby
    CreateSend::Segment.create(auth, list_id, title, rule_groups)
    CreateSend::Segment.update(title, rule_groups)
    ```

    So for example, when you _previously_ would have created an argument like so:

    ```ruby
    rules = [ { :Subject => "EmailAddress", :Clauses => [ "CONTAINS example.com" ] } ]
    ```

    You would _now_ do this:

    ```ruby
    rule_groups = [ { :Rules => [ { :RuleType => "EmailAddress", :Clause => "CONTAINS example.com" } ] } ]
    ```

  * The Add Rule call is now Add Rule Group, taking a collection of rules in a single `rule_group` argument instead of separate `subject` & `clauses` arguments.

    ```ruby
    CreateSend::Segment.add_rule_group(rule_group)
    ```

    So for example, when you _previously_ would have added a rule like so:

    ```ruby
    @segment.add_rule "EmailAddress", [ "CONTAINS example.com" ]
    ```

    You would _now_ do this:

    ```ruby
    @segment.add_rule_group [ { :RuleType => "EmailAddress", :Clause => "CONTAINS @hello.com" } ]
    ```

## v3.4.0 - 5 Jul, 2013

* Added support for validating SSL certificates to avoid man-in-the-middle attacks.

## v3.3.0 - 16 May, 2013

* Added Ruby version and platform details to default user agent string.
* Added support for setting a custom user agent string.

  You can set a custom user agent string to be used for API calls by doing the following:

  ```ruby
  CreateSend::CreateSend.user_agent "custom user agent"
  ```

## v3.2.0 - 15 Apr, 2013

* Added support for [single sign on](http://www.campaignmonitor.com/api/account/#single_sign_on) which allows initiation of external login sessions to Campaign Monitor.

## v3.1.1 - 10 Apr, 2013

* Fixed a bug occurring sometimes when refreshing OAuth access tokens, because of a URL encoding issue.

## v3.1.0 - 28 Mar, 2013

* Added `CreateSend::CreateSend.refresh_access_token` to allow easier refreshing of access tokens when using class methods.

    So you can now refresh an access token using _any_ refresh token like so:

    ```ruby
    access_token, expires_in, refresh_token =
      CreateSend::CreateSend.refresh_access_token 'refresh token'
    ```

    Or, you can refresh the _current_ access token (with your current refresh token) like so:

    ```ruby
    cs = CreateSend::CreateSend.new :access_token => 'access token',
      :refresh_token => 'refresh token'
    access_token, expires_in, refresh_token = cs.refresh_token
    ```

* Added `CreateSend::InvalidOAuthToken` and `CreateSend::RevokedOAuthToken` exceptions to make handling of OAuth exceptions in user code easier.

## v3.0.0 - 25 Mar, 2013

* Added support for authenticating using OAuth. See the [README](README.md#authenticating) for full usage instructions.
* Refactored authentication so that it is _always_ done at the instance level. This introduces some breaking changes, which are clearly explained below.
  * Authentication is now _always_ done at the instance level.

      So when you _previously_ would have authenticated using an API key as follows:

      ```ruby
      CreateSend.api_key "your api key"
      cs = CreateSend::CreateSend.new
      cs.clients
      ```

      If you want to authenticate using an API key, you should _now_ do this:

      ```ruby
      auth = {:api_key => "your api key"}
      cs = CreateSend::CreateSend.new auth
      cs.clients
      ```

  * Instances of `CreateSend::CreateSend` (and all subclasses) are now _always_ created by passing an `auth` hash as the first argument.

      So for example, when you _previously_ would have called `CreateSend::Client.new` like so:

      ```ruby
      CreateSend.api_key "your api key"
      cl = CreateSend::Client.new "your client id"
      ```

      You _now_ call `CreateSend::Client.new` like so:

      ```ruby
      auth = {:api_key => "your api key"}
      cl = CreateSend::Client.new auth, "your client id"
      ```

  * Any of the class methods on `CreateSend::CreateSend` (and all subclasses) are now _always_ called by passing an `auth` hash as the first argument.

      So for example, when you _previously_ would have called `CreateSend::Subscriber.add` like so:

      ```ruby
      CreateSend.api_key "your api key"
      sub = CreateSend::Subscriber.add "list id", "dave@example.com", "Dave", [], true
      ```

      You _now_ call `CreateSend::Subscriber.add` like so:

      ```ruby
      auth = {:api_key => "your api key"}
      sub = CreateSend::Subscriber.add auth, "list id", "dave@example.com", "Dave", [], true
      ```

## v2.5.1 - 4 Feb, 2013

* Updated dependencies in gemspec. Removed cane as a development dependency.

## v2.5.0 - 11 Dec, 2012

* Added support for including from name, from email, and reply to email in drafts, scheduled, and sent campaigns.
* Added support for campaign text version urls.
* Added support for transferring credits to/from a client.
* Added support for getting account billing details as well as client credits.
* Made all date fields optional when getting paged results.

## v2.4.0 - 5 Nov, 2012

* Added CreateSend::Campaign#email_client_usage.
* Added support for ReadsEmailWith field on subscriber objects.
* Added support for retrieving unconfirmed subscribers for a list.
* Added support for suppressing email addresses.
* Added support for retrieving spam complaints for a campaign, as well as
adding SpamComplaints field to campaign summary output.
* Added VisibleInPreferenceCenter field to custom field output.
* Added support for setting preference center visibility when creating custom
fields.
* Added the ability to update a custom field name and preference visibility.
* Added documentation explaining that text_url may now be nil or an empty
string when creating a campaign.

## v2.3.0 - 10 Oct, 2012

* Added support for creating campaigns from templates.
* Added support for unsuppressing an email address.
* Improved documentation and tests for getting active subscribers. Clearly
documented the data structure for multi option multi select fields.

## v2.2.0 - 17 Sep, 2012

* Added WorldviewURL field to campaign summary response.
* Added Latitude, Longitude, City, Region, CountryCode, and CountryName fields
to campaign opens and clicks response.

## v2.1.0 - 30 Aug, 2012

* Added support for basic / unlimited pricing.

## v2.0.0 - 22 Aug, 2012

* Added support for UnsubscribeSetting field when creating, updating and
getting list details.
* Added support for including AddUnsubscribesToSuppList and
ScrubActiveWithSuppList fields when updating a list.
* Added support for getting all client lists to which a subscriber with a
specific email address belongs.
* Removed deprecated warnings and disallowed calls to be made in a deprecated
manner.

## v1.1.1 - 24 Jul, 2012

* Added support for specifying whether subscription-based autoresponders
should be restarted when adding or updating subscribers.

## v1.1.0 - 11 Jul, 2012

* Added support for newly released team management functionality.

## v1.0.4 - 4 May, 2012

* Added Travis CI support.
* Added Gemnasium support.
* Fixes to usage of Shoulda and Hashie libraries.

## v1.0.3 - 3 Dec, 2011

* Fixes to support Ruby 1.9.* (both the library as well as the rake tasks).
* Fixed the User-Agent header so that it now uses the correct module VERSION.

## v1.0.2 - 31 Oct, 2011

* Added support for deleting a subscriber.
* Added support for specifying a 'clear' field when updating or importing
subscribers.
* Added support for queuing subscription-based autoresponders when importing
subscribers.
* Added support for retrieving deleted subscribers.
* Added support for including more social sharing stats in campaign summary.
* Added support for unscheduling a campaign.

## v1.0.1 - 25 Oct, 2011

* Remove CreateSendOptions and remove usage of yaml config file.

## v1.0.0 - 26 Sep, 2011

* Initial release which supports current Campaign Monitor API.
