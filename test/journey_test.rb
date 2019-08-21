require File.dirname(__FILE__) + '/helper'

class JourneyTest < Test::Unit::TestCase
  multiple_contexts "authenticated_using_oauth_context", "authenticated_using_api_key_context" do
    setup do
      @journey = CreateSend::Journey.new @auth, 'a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1'
    end

    should "get the summary for a journey" do
      stub_get(@auth, "journeys/#{@journey.journey_id}.json", "journey_summary.json")

      summary = @journey.summary
      summary.Name.should == 'New journey'
      summary.TriggerType.should == 'On Subscription'
      summary.Status.should == 'Active'

      summary.Emails.size.should == 1
      summary.Emails.first.EmailID.should == 'b1b1b1b1b1b1b1b1b1b1'
      summary.Emails.first.Name.should == 'New Email'
      summary.Emails.first.Bounced.should == 0
      summary.Emails.first.Clicks.should == 0
      summary.Emails.first.Opened.should == 3
      summary.Emails.first.Sent.should == 1
      summary.Emails.first.UniqueOpened.should == 1
      summary.Emails.first.Unsubscribed.should == 0
    end

    context "email recipients" do
      should "return a paged list of recipients of a particular email" do
        stub_get(@auth, "journeys/email/b1b1b1b1b1b1b1b1b1b1/recipients.json", "journey_recipients.json")

        recipients = @journey.email_recipients 'b1b1b1b1b1b1b1b1b1b1'
        recipients.Results.size.should == 4
        recipients.Results.first.EmailAddress.should == 'example+1@example.com'
        recipients.Results.first.SentDate.should == '2019-07-12 09:45:00'

        recipients.ResultsOrderedBy.should == 'SentDate'
        recipients.OrderDirection.should == 'ASC'
        recipients.PageNumber.should == 2
        recipients.PageSize.should == 10
        recipients.RecordsOnThisPage.should == 4
        recipients.TotalNumberOfRecords.should == 14
        recipients.NumberOfPages.should == 2
      end

      should "validate argument when getting email recipients" do
        [nil, 5].each { |id|
          lambda { @journey.email_recipients id }.should raise_error
        }
      end
    end

    should "return a paged list of subscribers who opened given journey email" do
      journey_date = "2019-02-08 09:22"
      stub_get(@auth, "journeys/email/b1b1b1b1b1b1b1b1b1b1/opens.json" \
        "?date=#{ERB::Util.url_encode(journey_date)}" \
        "&page=2" \
        "&pagesize=5" \
        "&orderfield=date" \
        "&orderdirection=asc", "journey_opens.json")

      opens = @journey.email_opens email = 'b1b1b1b1b1b1b1b1b1b1', date = journey_date, page = 2, page_size = 5, order_direction = 'asc'
      opens.Results.size.should == 4
      opens.Results.last.EmailAddress.should == "example+4@example.com"
      opens.Results.last.Date.should == "2019-07-29 10:35:00"
      opens.Results.last.IPAddress.should == "192.168.0.3"
      opens.Results.last.Latitude.should == -33.8683
      opens.Results.last.Longitude.should == 151.2086
      opens.Results.last.City.should == "Sydney"
      opens.Results.last.Region.should == "New South Wales"
      opens.Results.last.CountryCode.should == "AU"
      opens.Results.last.CountryName.should == "Australia"

      opens.ResultsOrderedBy.should == "Date"
      opens.OrderDirection.should == "ASC"
      opens.PageNumber.should == 1
      opens.PageSize.should == 1000
      opens.RecordsOnThisPage.should == 4
      opens.TotalNumberOfRecords.should == 4
      opens.NumberOfPages.should == 1
    end

    should "return a paged list of subscribers who clicked on a journey email" do
      journey_date = "2019-07-29 10:30"
      stub_get(@auth, "journeys/email/b1b1b1b1b1b1b1b1b1b1/clicks.json" \
        "?date=#{ERB::Util.url_encode(journey_date)}" \
        "&page=1" \
        "&pagesize=2" \
        "&orderfield=date" \
        "&orderdirection=asc", "journey_clicks.json")

      clicks = @journey.email_clicks email = 'b1b1b1b1b1b1b1b1b1b1', date = journey_date, page = 1, page_size = 2, order_direction = 'asc'
      clicks.Results.size.should == 2
      clicks.Results.first.EmailAddress.should == "example+1@example.com"
      clicks.Results.first.Date.should == "2019-07-29 10:33:00"
      clicks.Results.first.URL.should == "http://test.com"
      clicks.Results.first.IPAddress.should == "192.168.0.3"
      clicks.Results.first.Latitude.should == -33.8683
      clicks.Results.first.Longitude.should == 151.2086
      clicks.Results.first.City.should == "Sydney"
      clicks.Results.first.Region.should == "New South Wales"
      clicks.Results.first.CountryCode.should == "AU"
      clicks.Results.first.CountryName.should == "Australia"

      clicks.ResultsOrderedBy.should == "Date"
      clicks.OrderDirection.should == "ASC"
      clicks.PageNumber.should == 1
      clicks.PageSize.should == 2
      clicks.RecordsOnThisPage.should == 2
      clicks.TotalNumberOfRecords.should == 5
      clicks.NumberOfPages.should == 3
    end

    should "return a paged list of subscribers who unsubscribed from a journey email" do
      journey_date = "2019-07-29 10:22"
      stub_get(@auth, "journeys/email/b1b1b1b1b1b1b1b1b1b1/unsubscribes.json" \
        "?date=#{ERB::Util.url_encode(journey_date)}" \
        "&page=1" \
        "&pagesize=10" \
        "&orderfield=date" \
        "&orderdirection=desc", "journey_unsubscribes.json")

      unsubscribes = @journey.email_unsubscribes email = 'b1b1b1b1b1b1b1b1b1b1', date = journey_date, page = 1, page_size = 10, order_direction = 'desc'
      unsubscribes.Results.size.should == 3
      unsubscribes.Results.first.EmailAddress.should == "example+1@example.com"
      unsubscribes.Results.first.Date.should == "2019-07-29 10:33:00"
      unsubscribes.Results.first.IPAddress.should == "192.168.0.3"

      unsubscribes.ResultsOrderedBy.should == "Date"
      unsubscribes.OrderDirection.should == "ASC"
      unsubscribes.PageNumber.should == 1
      unsubscribes.PageSize.should == 1000
      unsubscribes.RecordsOnThisPage.should == 4
      unsubscribes.TotalNumberOfRecords.should == 4
      unsubscribes.NumberOfPages.should == 1
    end

    should "return a paged list of emails that bounced for a journey email" do
      journey_date = "2019-07-29 10:31"
      stub_get(@auth, "journeys/email/b1b1b1b1b1b1b1b1b1b1/bounces.json" \
        "?date=#{ERB::Util.url_encode(journey_date)}" \
        "&page=20" \
        "&pagesize=5" \
        "&orderfield=date" \
        "&orderdirection=desc", "journey_bounces.json")

      bounces = @journey.email_bounces email = 'b1b1b1b1b1b1b1b1b1b1', date = journey_date, page = 20, page_size = 5, order_direction = 'desc'
      bounces.Results.size.should == 4
      bounces.Results.first.EmailAddress.should == "example+1@example.com"
      bounces.Results.first.BounceType.should == "4"
      bounces.Results.first.Date.should == "2019-07-29 10:33:00"
      bounces.Results.first.Reason.should == "Soft Bounce - Mailbox Full"

      bounces.ResultsOrderedBy.should == "Date"
      bounces.OrderDirection.should == "ASC"
      bounces.PageNumber.should == 1
      bounces.PageSize.should == 1000
      bounces.RecordsOnThisPage.should == 4
      bounces.TotalNumberOfRecords.should == 4
      bounces.NumberOfPages.should == 1
    end
  end
end