require File.dirname(__FILE__) + '/helper'

class JourneyTest < Test::Unit::TestCase
  multiple_contexts "authenticated_using_oauth_context", "authenticated_using_api_key_context" do
    setup do
      @journey = CreateSend::Journey.new @auth, 'a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1'
    end

    should "get the summary for a journey" do
      stub_get(@auth, "journeys/#{@journey.journey_id}.json", "journey_summary.json")

      summary = @journey.summary
      summary.Name.should be == 'New journey'
      summary.TriggerType.should be == 'On Subscription'
      summary.Status.should be == 'Active'

      summary.Emails.size.should be == 1
      summary.Emails.first.EmailID.should be == 'b1b1b1b1b1b1b1b1b1b1'
      summary.Emails.first.Name.should be == 'New Email'
      summary.Emails.first.Bounced.should be == 0
      summary.Emails.first.Clicked.should be == 0
      summary.Emails.first.Opened.should be == 3
      summary.Emails.first.Sent.should be == 1
      summary.Emails.first.UniqueOpened.should be == 1
      summary.Emails.first.Unsubscribed.should be == 0
    end

    should "return a paged list of recipients of a particular email" do
      journey_date = "2019-07-12 09:22"
      stub_get(@auth, "journeys/email/b1b1b1b1b1b1b1b1b1b1/recipients.json" \
        "?date=#{ERB::Util.url_encode(journey_date)}" \
        "&page=2" \
        "&pagesize=5" \
        "&orderdirection=asc", "journey_recipients.json")

      recipients = @journey.email_recipients email_id = 'b1b1b1b1b1b1b1b1b1b1', date = journey_date, page = 2, page_size = 5, order_direction = 'asc'
      recipients.Results.size.should be == 4
      recipients.Results.first.EmailAddress.should be == 'example+1@example.com'
      recipients.Results.first.SentDate.should be == '2019-07-12 09:45:00'

      recipients.ResultsOrderedBy.should be == 'SentDate'
      recipients.OrderDirection.should be == 'ASC'
      recipients.PageNumber.should be == 2
      recipients.PageSize.should be == 10
      recipients.RecordsOnThisPage.should be == 4
      recipients.TotalNumberOfRecords.should be == 14
      recipients.NumberOfPages.should be == 2
    end

    should "return a paged list of subscribers who opened given journey email" do
      journey_date = "2019-02-08 09:22"
      stub_get(@auth, "journeys/email/b1b1b1b1b1b1b1b1b1b1/opens.json" \
        "?date=#{ERB::Util.url_encode(journey_date)}" \
        "&page=2" \
        "&pagesize=5" \
        "&orderdirection=asc", "journey_opens.json")

      opens = @journey.email_opens email = 'b1b1b1b1b1b1b1b1b1b1', date = journey_date, page = 2, page_size = 5, order_direction = 'asc'
      opens.Results.size.should be == 4
      opens.Results.last.EmailAddress.should be == "example+4@example.com"
      opens.Results.last.Date.should be == "2019-07-29 10:35:00"
      opens.Results.last.IPAddress.should be == "192.168.0.3"
      opens.Results.last.Latitude.should be == -33.8683
      opens.Results.last.Longitude.should be == 151.2086
      opens.Results.last.City.should be == "Sydney"
      opens.Results.last.Region.should be == "New South Wales"
      opens.Results.last.CountryCode.should be == "AU"
      opens.Results.last.CountryName.should be == "Australia"

      opens.ResultsOrderedBy.should be == "Date"
      opens.OrderDirection.should be == "ASC"
      opens.PageNumber.should be == 1
      opens.PageSize.should be == 1000
      opens.RecordsOnThisPage.should be == 4
      opens.TotalNumberOfRecords.should be == 4
      opens.NumberOfPages.should be == 1
    end

    should "return a paged list of subscribers who clicked on a journey email" do
      journey_date = "2019-07-29 10:30"
      stub_get(@auth, "journeys/email/b1b1b1b1b1b1b1b1b1b1/clicks.json" \
        "?date=#{ERB::Util.url_encode(journey_date)}" \
        "&page=1" \
        "&pagesize=2" \
        "&orderdirection=asc", "journey_clicks.json")

      clicks = @journey.email_clicks email = 'b1b1b1b1b1b1b1b1b1b1', date = journey_date, page = 1, page_size = 2, order_direction = 'asc'
      clicks.Results.size.should be == 2
      clicks.Results.first.EmailAddress.should be == "example+1@example.com"
      clicks.Results.first.Date.should be == "2019-07-29 10:33:00"
      clicks.Results.first.URL.should be == "http://test.com"
      clicks.Results.first.IPAddress.should be == "192.168.0.3"
      clicks.Results.first.Latitude.should be == -33.8683
      clicks.Results.first.Longitude.should be == 151.2086
      clicks.Results.first.City.should be == "Sydney"
      clicks.Results.first.Region.should be == "New South Wales"
      clicks.Results.first.CountryCode.should be == "AU"
      clicks.Results.first.CountryName.should be == "Australia"

      clicks.ResultsOrderedBy.should be == "Date"
      clicks.OrderDirection.should be == "ASC"
      clicks.PageNumber.should be == 1
      clicks.PageSize.should be == 2
      clicks.RecordsOnThisPage.should be == 2
      clicks.TotalNumberOfRecords.should be == 5
      clicks.NumberOfPages.should be == 3
    end

    should "return a paged list of subscribers who unsubscribed from a journey email" do
      journey_date = "2019-07-29 10:22"
      stub_get(@auth, "journeys/email/b1b1b1b1b1b1b1b1b1b1/unsubscribes.json" \
        "?date=#{ERB::Util.url_encode(journey_date)}" \
        "&page=1" \
        "&pagesize=10" \
        "&orderdirection=desc", "journey_unsubscribes.json")

      unsubscribes = @journey.email_unsubscribes email = 'b1b1b1b1b1b1b1b1b1b1', date = journey_date, page = 1, page_size = 10, order_direction = 'desc'
      unsubscribes.Results.size.should be == 3
      unsubscribes.Results.first.EmailAddress.should be == "example+1@example.com"
      unsubscribes.Results.first.Date.should be == "2019-07-29 10:33:00"
      unsubscribes.Results.first.IPAddress.should be == "192.168.0.3"

      unsubscribes.ResultsOrderedBy.should be == "Date"
      unsubscribes.OrderDirection.should be == "ASC"
      unsubscribes.PageNumber.should be == 1
      unsubscribes.PageSize.should be == 1000
      unsubscribes.RecordsOnThisPage.should be == 4
      unsubscribes.TotalNumberOfRecords.should be == 4
      unsubscribes.NumberOfPages.should be == 1
    end

    should "return a paged list of emails that bounced for a journey email" do
      journey_date = "2019-07-29 10:31"
      stub_get(@auth, "journeys/email/b1b1b1b1b1b1b1b1b1b1/bounces.json" \
        "?date=#{ERB::Util.url_encode(journey_date)}" \
        "&page=20" \
        "&pagesize=5" \
        "&orderdirection=desc", "journey_bounces.json")

      bounces = @journey.email_bounces email = 'b1b1b1b1b1b1b1b1b1b1', date = journey_date, page = 20, page_size = 5, order_direction = 'desc'
      bounces.Results.size.should be == 4
      bounces.Results.first.EmailAddress.should be == "example+1@example.com"
      bounces.Results.first.BounceType.should be == "4"
      bounces.Results.first.Date.should be == "2019-07-29 10:33:00"
      bounces.Results.first.Reason.should be == "Soft Bounce - Mailbox Full"

      bounces.ResultsOrderedBy.should be == "Date"
      bounces.OrderDirection.should be == "ASC"
      bounces.PageNumber.should be == 1
      bounces.PageSize.should be == 1000
      bounces.RecordsOnThisPage.should be == 4
      bounces.TotalNumberOfRecords.should be == 4
      bounces.NumberOfPages.should be == 1
    end
  end
end