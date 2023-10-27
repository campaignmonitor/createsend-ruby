require File.dirname(__FILE__) + '/helper'

class ClientTest < Test::Unit::TestCase
  multiple_contexts "authenticated_using_oauth_context", "authenticated_using_api_key_context" do
    setup do
      @client = CreateSend::Client.new(@auth, '321iuhiuhi1u23hi2u3')
      @client.client_id.should be == '321iuhiuhi1u23hi2u3'
    end

    should "create a client" do
      stub_post(@auth, "clients.json", "create_client.json")
      client_id = CreateSend::Client.create @auth, "Client Company Name", "(GMT+10:00) Canberra, Melbourne, Sydney", "Australia"
      client_id.parsed_response.should be == "32a381c49a2df99f1d0c6f3c112352b9"
    end

    should "get details of a client" do
      stub_get(@auth, "clients/#{@client.client_id}.json", "client_details.json")
      cl = @client.details
      cl.ApiKey.should be == "639d8cc27198202f5fe6037a8b17a29a59984b86d3289bc9"
      cl.BasicDetails.ClientID.should be == "4a397ccaaa55eb4e6aa1221e1e2d7122"
      cl.BasicDetails.ContactName.should be == "Client One (contact)"
      cl.AccessDetails.Username.should be == "clientone"
      cl.AccessDetails.AccessLevel.should be == 23
      cl.BillingDetails.MonthlyScheme.should be == "Basic"
      cl.BillingDetails.Credits.should be == 500
    end

    should "get all campaigns" do
      stub_get(@auth, "clients/#{@client.client_id}/campaigns.json?page=1&pagesize=1000&orderdirection=desc&sentfromdate=&senttodate=&tags=", "campaigns.json")
      campaigns = @client.campaigns
      campaigns.Results.size.should be == 2
      campaigns.ResultsOrderedBy be == 'sentdate'
      campaigns.OrderDirection be == 'desc'
      campaigns.PageNumber be == 1
      campaigns.PageSize be == 1000
      campaigns.RecordsOnThisPage be == 2
      campaigns.TotalNumberOfRecords be == 2
      campaigns.NumberOfPages be == 1

      campaign = campaigns.Results.first
      campaign.CampaignID.should be == 'fc0ce7105baeaf97f47c99be31d02a91'
      campaign.WebVersionURL.should be == 'http://createsend.com/t/r-765E86829575EE2C'
      campaign.WebVersionTextURL.should be == 'http://createsend.com/t/r-765E86829575EE2C/t'
      campaign.Subject.should be == 'Campaign One'
      campaign.Name.should be == 'Campaign One'
      campaign.SentDate.should be == '2010-10-12 12:58:00'
      campaign.TotalRecipients.should be == 2245
      campaign.FromName.should be == 'My Name'
      campaign.FromEmail.should be == 'myemail@example.com'
      campaign.ReplyTo.should be == 'myemail@example.com'
      campaign.Tags.should be == []
    end

    should "get scheduled campaigns" do
      stub_get(@auth, "clients/#{@client.client_id}/scheduled.json", "scheduled_campaigns.json")
      campaigns = @client.scheduled
      campaigns.size.should be == 2
      campaign = campaigns.first
      campaign.DateScheduled.should be == "2011-05-25 10:40:00"
      campaign.ScheduledTimeZone.should be == "(GMT+10:00) Canberra, Melbourne, Sydney"
      campaign.CampaignID.should be == "827dbbd2161ea9989fa11ad562c66937"
      campaign.Name.should be == "Magic Issue One"
      campaign.Subject.should be == "Magic Issue One"
      campaign.DateCreated.should be == "2011-05-24 10:37:00"
      campaign.PreviewURL.should be == "http://createsend.com/t/r-DD543521A87C9B8B"
      campaign.PreviewTextURL.should be == "http://createsend.com/t/r-DD543521A87C9B8B/t"
      campaign.FromName.should be == 'My Name'
      campaign.FromEmail.should be == 'myemail@example.com'
      campaign.ReplyTo.should be == 'myemail@example.com'
      campaign.Tags.should be == ['tagexample']
    end

    should "get all drafts" do
      stub_get(@auth, "clients/#{@client.client_id}/drafts.json", "drafts.json")
      drafts = @client.drafts
      drafts.size.should be == 2
      draft = drafts.first
      draft.CampaignID.should be == '7c7424792065d92627139208c8c01db1'
      draft.Name.should be == 'Draft One'
      draft.Subject.should be == 'Draft One'
      draft.DateCreated.should be == '2010-08-19 16:08:00'
      draft.PreviewURL.should be == 'http://createsend.com/t/r-E97A7BB2E6983DA1'
      draft.PreviewTextURL.should be == 'http://createsend.com/t/r-E97A7BB2E6983DA1/t'
      draft.FromName.should be == 'My Name'
      draft.FromEmail.should be == 'myemail@example.com'
      draft.ReplyTo.should be == 'myemail@example.com'
      draft.Tags.should be == ['tagexample']
    end

    should "get all client tags" do
      stub_get(@auth, "clients/#{@client.client_id}/tags.json", "tags.json")
      tags = @client.tags
      tags.size.should be == 2
      tag = tags.first
      tag.Name.should be == 'Tag One'
      tag.NumberOfCampaigns.should be == '120'
    end

    should "get all lists" do
      stub_get(@auth, "clients/#{@client.client_id}/lists.json", "lists.json")
      lists = @client.lists
      lists.size.should be == 2
      lists.first.ListID.should be == 'a58ee1d3039b8bec838e6d1482a8a965'
      lists.first.Name.should be == 'List One'
    end

    should "get all lists to which a subscriber with a particular email address belongs" do
      email = "valid@example.com"
      stub_get(@auth, "clients/#{@client.client_id}/listsforemail.json?email=#{ERB::Util.url_encode(email)}", "listsforemail.json")
      lists = @client.lists_for_email(email)
      lists.size.should be == 2
      lists.first.ListID.should be == 'ab4a2b57c7c8f1ba62f898a1af1a575b'
      lists.first.ListName.should be == 'List Number One'
      lists.first.SubscriberState.should be == 'Active'
      lists.first.DateSubscriberAdded.should be == '2012-08-20 22:32:00'
    end

    should "get all segments for a client" do
      stub_get(@auth, "clients/#{@client.client_id}/segments.json", "segments.json")
      segments = @client.segments
      segments.size.should be == 2
      segments.first.ListID.should be == 'a58ee1d3039b8bec838e6d1482a8a965'
      segments.first.SegmentID.should be == '46aa5e01fd43381863d4e42cf277d3a9'
      segments.first.Title.should be == 'Segment One'
    end

    should "get suppression list" do
      stub_get(@auth, "clients/#{@client.client_id}/suppressionlist.json?pagesize=1000&orderfield=email&page=1&orderdirection=asc", "suppressionlist.json")
      res = @client.suppressionlist
      res.ResultsOrderedBy.should be == "email"
      res.OrderDirection.should be == "asc"
      res.PageNumber.should be == 1
      res.PageSize.should be == 1000
      res.RecordsOnThisPage.should be == 5
      res.TotalNumberOfRecords.should be == 5
      res.NumberOfPages.should be == 1
      res.Results.size.should be == 5
      res.Results.first.SuppressionReason.should be == "Unsubscribed"
      res.Results.first.EmailAddress.should be == "example+1@example.com"
      res.Results.first.Date.should be == "2010-10-26 10:55:31"
      res.Results.first.State.should be == "Suppressed"
    end

    should "suppress a single email address" do
      email = "example@example.com"
      stub_post(@auth, "clients/#{@client.client_id}/suppress.json", nil)
      @client.suppress email
    end

    should "suppress multiple email address" do
      stub_post(@auth, "clients/#{@client.client_id}/suppress.json", nil)
      @client.suppress [ "one@example.com", "two@example.com" ]
    end

    should "unsuppress an email address" do
      email = "example@example.com"
      stub_put(@auth, "clients/#{@client.client_id}/unsuppress.json?email=#{ERB::Util.url_encode(email)}", nil)
      @client.unsuppress email
    end

    should "get all people" do
      stub_get(@auth, "clients/#{@client.client_id}/people.json", "people.json")
      people = @client.people
      people.size.should be == 2
      people.first.EmailAddress.should be == "person1@blackhole.com"
      people.first.Name.should be == "Person One"
      people.first.Status.should be == "Active"
      people.first.AccessLevel.should be == 31
    end

    should "get all templates" do
      stub_get(@auth, "clients/#{@client.client_id}/templates.json", "templates.json")
      templates = @client.templates
      templates.size.should be == 2
      templates.first.TemplateID.should be == '5cac213cf061dd4e008de5a82b7a3621'
      templates.first.Name.should be == 'Template One'
    end

    should "set primary contact" do
      email = 'person@blackhole.com'
      stub_put(@auth, "clients/#{@client.client_id}/primarycontact.json?email=#{ERB::Util.url_encode(email)}", 'client_set_primary_contact.json')
      result = @client.set_primary_contact email
      result.EmailAddress.should be == email
    end

    should "get primary contact" do
      stub_get(@auth, "clients/#{@client.client_id}/primarycontact.json", 'client_get_primary_contact.json')
      result = @client.get_primary_contact
      result.EmailAddress.should be == 'person@blackhole.com'
    end

    should "set basics" do
      stub_put(@auth, "clients/#{@client.client_id}/setbasics.json", nil)
      @client.set_basics "Client Company Name", "(GMT+10:00) Canberra, Melbourne, Sydney", "Australia"
    end

    should "set payg billing" do
      stub_put(@auth, "clients/#{@client.client_id}/setpaygbilling.json", nil)
      @client.set_payg_billing "CAD", true, true, 150
    end

    should "set monthly billing (implicit)" do
      stub_put(@auth, "clients/#{@client.client_id}/setmonthlybilling.json", nil)
      @client.set_monthly_billing "CAD", true, 150 
      request = FakeWeb.last_request.body
      request.include?("\"Currency\":\"CAD\"").should be == true
      request.include?("\"ClientPays\":true").should be == true
      request.include?("\"MarkupPercentage\":150").should be == true
      request.include?("\"MonthlyScheme\":null").should be == true
    end

    should "set monthly billing (basic)" do
      stub_put(@auth, "clients/#{@client.client_id}/setmonthlybilling.json", nil)
      @client.set_monthly_billing "CAD", true, 150, "Basic"
      request = FakeWeb.last_request.body
      request.include?("\"Currency\":\"CAD\"").should be == true
      request.include?("\"ClientPays\":true").should be == true
      request.include?("\"MarkupPercentage\":150").should be == true
      request.include?("\"MonthlyScheme\":\"Basic\"").should be == true
    end
       
    should "set monthly billing (unlimited)" do
      stub_put(@auth, "clients/#{@client.client_id}/setmonthlybilling.json", nil)
      @client.set_monthly_billing "CAD", false, 120, "Unlimited"
      request = FakeWeb.last_request.body
      request.include?("\"Currency\":\"CAD\"").should be == true
      request.include?("\"ClientPays\":false").should be == true
      request.include?("\"MarkupPercentage\":120").should be == true
      request.include?("\"MonthlyScheme\":\"Unlimited\"").should be == true
    end

    should "transfer credits to a client" do
      stub_post(@auth, "clients/#{@client.client_id}/credits.json", "transfer_credits.json")
      result = @client.transfer_credits 200, false
      result.AccountCredits.should be == 800
      result.ClientCredits.should be == 200
    end

    should "delete a client" do
      stub_delete(@auth, "clients/#{@client.client_id}.json", nil)
      @client.delete
    end

    should "get all journeys" do
      stub_get(@auth, "clients/#{@client.client_id}/journeys.json", "journeys.json")
      lists = @client.journeys
      lists.size.should be == 3
      lists.first.ListID.should be == 'a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a'
      lists.first.Name.should be == 'Journey One'
      lists.first.Status.should be == 'Not started'
    end
  end
end
