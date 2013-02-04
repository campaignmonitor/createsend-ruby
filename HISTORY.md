# createsend-ruby history

## v2.5.1 - 4 Feb, 2013   (f0a35ae)

* Updated dependencies in gemspec. Removed cane as a development dependency.

## v2.5.0 - 11 Dec, 2012   (3054885)

* Added support for including from name, from email, and reply to email in
drafts, scheduled, and sent campaigns.
* Added support for campaign text version urls.
* Added support for transferring credits to/from a client.
* Added support for getting account billing details as well as client credits.
* Made all date fields optional when getting paged results.

## v2.4.0 - 5 Nov, 2012   (4277d8d9)

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

## v2.3.0 - 10 Oct, 2012   (6639c1f6)

* Added support for creating campaigns from templates.
* Added support for unsuppressing an email address.
* Improved documentation and tests for getting active subscribers. Clearly
documented the data structure for multi option multi select fields.

## v2.2.0 - 17 Sep, 2012   (17409634)

* Added WorldviewURL field to campaign summary response.
* Added Latitude, Longitude, City, Region, CountryCode, and CountryName fields
to campaign opens and clicks response.

## v2.1.0 - 30 Aug, 2012   (ee936259)

* Added support for basic / unlimited pricing.

## v2.0.0 - 22 Aug, 2012   (8a5ab6b4)

* Added support for UnsubscribeSetting field when creating, updating and
getting list details.
* Added support for including AddUnsubscribesToSuppList and
ScrubActiveWithSuppList fields when updating a list.
* Added support for getting all client lists to which a subscriber with a
specific email address belongs.
* Removed deprecated warnings and disallowed calls to be made in a deprecated
manner.

## v1.1.1 - 24 Jul, 2012   (72934e66)

* Added support for specifying whether subscription-based autoresponders
should be restarted when adding or updating subscribers.

## v1.1.0 - 11 Jul, 2012   (93e856b6)

* Added support for newly released team management functionality.

## v1.0.4 - 4 May, 2012   (9bce25c1)

* Added Travis CI support.
* Added Gemnasium support.
* Fixes to usage of Shoulda and Hashie libraries.

## v1.0.3 - 3 Dec, 2011   (1ed2b56a)

* Fixes to support Ruby 1.9.* (both the library as well as the rake tasks).
* Fixed the User-Agent header so that it now uses the correct module VERSION.

## v1.0.2 - 31 Oct, 2011   (83020409)

* Added support for deleting a subscriber.
* Added support for specifying a 'clear' field when updating or importing
subscribers.
* Added support for queuing subscription-based autoresponders when importing
subscribers.
* Added support for retrieving deleted subscribers.
* Added support for including more social sharing stats in campaign summary.
* Added support for unscheduling a campaign.

## v1.0.1 - 25 Oct, 2011   (347b2b95)

* Remove CreateSendOptions and remove usage of yaml config file.

## v1.0.0 - 26 Sep, 2011   (0a078b09)

* Initial release which supports current Campaign Monitor API.
