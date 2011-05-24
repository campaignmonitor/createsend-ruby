require File.dirname(__FILE__) + '/helper'

class ClientTest < Test::Unit::TestCase
  context "when an api caller is authenticated" do
    setup do
      @api_key = '123123123123123123123'
      CreateSend.api_key @api_key
      @client = CreateSend::Client.new('321iuhiuhi1u23hi2u3')
      @client.client_id.should == '321iuhiuhi1u23hi2u3'
    end

    should "create a client" do
      stub_post(@api_key, "clients.json", "create_client.json")
      client_id = CreateSend::Client.create "Client Company Name", "Client Contact Name", "client@example.com", "(GMT+10:00) Canberra, Melbourne, Sydney", "Australia"
      client_id.should == "32a381c49a2df99f1d0c6f3c112352b9"
    end
    
    should "get details of a client" do
      stub_get(@api_key, "clients/#{@client.client_id}.json", "client_details.json")
      cl = @client.details
      cl.ApiKey.should == "639d8cc27198202f5fe6037a8b17a29a59984b86d3289bc9"
      cl.BasicDetails.ClientID.should == "4a397ccaaa55eb4e6aa1221e1e2d7122"
      cl.BasicDetails.ContactName.should == "Client One (contact)"
      cl.AccessDetails.Username.should == "clientone"
      cl.AccessDetails.AccessLevel.should == 23
    end

    should "get all campaigns" do
      stub_get(@api_key, "clients/#{@client.client_id}/campaigns.json", "campaigns.json")
      campaigns = @client.campaigns
      campaigns.size.should == 2
      campaigns.first.CampaignID.should == 'fc0ce7105baeaf97f47c99be31d02a91'
      campaigns.first.WebVersionURL.should == 'http://createsend.com/t/r-765E86829575EE2C'
      campaigns.first.Subject.should == 'Campaign One'
      campaigns.first.Name.should == 'Campaign One'
      campaigns.first.SentDate.should == '2010-10-12 12:58:00'
      campaigns.first.TotalRecipients.should == 2245
    end

    should "get scheduled campaigns" do
      stub_get(@api_key, "clients/#{@client.client_id}/scheduled.json", "scheduled_campaigns.json")
      campaigns = @client.scheduled
      campaigns.size.should == 2
      campaigns.first.DateScheduled.should == "2011-05-25 10:40:00"
      campaigns.first.ScheduledTimeZone.should == "(GMT+10:00) Canberra, Melbourne, Sydney"
      campaigns.first.CampaignID.should == "827dbbd2161ea9989fa11ad562c66937"
      campaigns.first.Name.should == "Magic Issue One"
      campaigns.first.Subject.should == "Magic Issue One"
      campaigns.first.DateCreated.should == "2011-05-24 10:37:00"
      campaigns.first.PreviewURL.should == "http://createsend.com/t/r-DD543521A87C9B8B"
    end

    should "get all drafts" do
      stub_get(@api_key, "clients/#{@client.client_id}/drafts.json", "drafts.json")
      drafts = @client.drafts
      drafts.size.should == 2
      drafts.first.CampaignID.should == '7c7424792065d92627139208c8c01db1'
      drafts.first.Name.should == 'Draft One'
      drafts.first.Subject.should == 'Draft One'
      drafts.first.DateCreated.should == '2010-08-19 16:08:00'
      drafts.first.PreviewURL.should == 'http://createsend.com/t/r-E97A7BB2E6983DA1'
    end

    should "get all lists" do
      stub_get(@api_key, "clients/#{@client.client_id}/lists.json", "lists.json")
      lists = @client.lists
      lists.size.should == 2
      lists.first.ListID.should == 'a58ee1d3039b8bec838e6d1482a8a965'
      lists.first.Name.should == 'List One'
    end
    
    should "get all segments for a client" do
      stub_get(@api_key, "clients/#{@client.client_id}/segments.json", "segments.json")
      segments = @client.segments
      segments.size.should == 2
      segments.first.ListID.should == 'a58ee1d3039b8bec838e6d1482a8a965'
      segments.first.SegmentID.should == '46aa5e01fd43381863d4e42cf277d3a9'
      segments.first.Title.should == 'Segment One'
    end

    should "get suppression list" do
      stub_get(@api_key, "clients/#{@client.client_id}/suppressionlist.json?pagesize=1000&orderfield=email&page=1&orderdirection=asc", "suppressionlist.json")
      res = @client.suppressionlist
      res.ResultsOrderedBy.should == "email"
      res.OrderDirection.should == "asc"
      res.PageNumber.should == 1
      res.PageSize.should == 1000
      res.RecordsOnThisPage.should == 5
      res.TotalNumberOfRecords.should == 5
      res.NumberOfPages.should == 1
      res.Results.size.should == 5
      res.Results.first.SuppressionReason.should == "Unsubscribed"
      res.Results.first.EmailAddress.should == "example+1@example.com"
      res.Results.first.Date.should == "2010-10-26 10:55:31"
      res.Results.first.State.should == "Suppressed"
    end

    should "get all templates" do
      stub_get(@api_key, "clients/#{@client.client_id}/templates.json", "templates.json")
      templates = @client.templates
      templates.size.should == 2
      templates.first.TemplateID.should == '5cac213cf061dd4e008de5a82b7a3621'
      templates.first.Name.should == 'Template One'
    end
    
    should "set basics" do
      stub_put(@api_key, "clients/#{@client.client_id}/setbasics.json", nil)
      @client.set_basics "Client Company Name", "Client Contact Name", "client@example.com", "(GMT+10:00) Canberra, Melbourne, Sydney", "Australia"
    end
    
    should "set access" do
      stub_put(@api_key, "clients/#{@client.client_id}/setaccess.json", nil)
      @client.set_access "username", "password", 321
    end
    
    should "set payg billing" do
      stub_put(@api_key, "clients/#{@client.client_id}/setpaygbilling.json", nil)
      @client.set_payg_billing "CAD", true, true, 150
    end
    
    should "set monthly billing" do
      stub_put(@api_key, "clients/#{@client.client_id}/setmonthlybilling.json", nil)
      @client.set_monthly_billing "CAD", true, 150
    end
    
    should "delete a client" do
      stub_delete(@api_key, "clients/#{@client.client_id}.json", nil)
      @client.delete
    end
    
  end
end
