require File.dirname(__FILE__) + '/helper'

class ClientTest < Test::Unit::TestCase
  context "when an api caller is authenticated" do
    setup do
      @api_key = '123123123123123123123'
      @base_uri = 'http://api.createsend.com/api/v3'
      @cs = CreateSend.new(:api_key => @api_key, :base_uri => @base_uri)
      @client = Client.new(:client_id => '321iuhiuhi1u23hi2u3')
    end

    should "create a client" do
      stub_post(@api_key, "clients.json", "create_client.json")
      client_id = Client.create "Client Company Name", "Client Contact Name", "client@example.com", "(GMT+10:00) Canberra, Melbourne, Sydney", "Australia"
      client_id.should == "32a381c49a2df99f1d0c6f3c112352b9"
    end
    
    should "get details of a client" do
      stub_get(@api_key, "clients/#{@client.client_id}.json", "client_details.json")
      cl = @client.details
      cl.BasicDetails.ClientID.should == "4a397ccaaa55eb4e6aa1221e1e2d7122"
      cl.BasicDetails.ContactName.should == "Client One (contact)"
      cl.AccessAndBilling.Username.should == "clientone"
    end

    should "get all campaigns" do
      stub_get(@api_key, "clients/#{@client.client_id}/campaigns.json", "campaigns.json")
      campaigns = @client.campaigns
      campaigns.size.should == 2
      campaigns.first.CampaignID.should == 'fc0ce7105baeaf97f47c99be31d02a91'
      campaigns.first.WebVersionURL.should == 'http://hello.createsend.com//t/ViewEmail/r/765E86829575EE2C/C67FD2F38AC4859C/'
      campaigns.first.Subject.should == 'Campaign One'
      campaigns.first.Name.should == 'Campaign One'
      campaigns.first.SentDate.should == '2010-10-12 12:58:00'
      campaigns.first.TotalRecipients.should == 2245
    end

    should "get all drafts" do
      stub_get(@api_key, "clients/#{@client.client_id}/drafts.json", "drafts.json")
      drafts = @client.drafts
      drafts.size.should == 2
      drafts.first.CampaignID.should == '7c7424792065d92627139208c8c01db1'
      drafts.first.Name.should == 'Draft One'
      drafts.first.Subject.should == 'Draft One'
      drafts.first.DateCreated.should == '2010-08-19 16:08:00'
    end

    should "get all lists" do
      stub_get(@api_key, "clients/#{@client.client_id}/lists.json", "lists.json")
      lists = @client.lists
      lists.size.should == 2
      lists.first.ListID.should == 'a58ee1d3039b8bec838e6d1482a8a965'
      lists.first.Name.should == 'List One'
    end
    
    should "get all segments" do
      stub_get(@api_key, "clients/#{@client.client_id}/segments.json", "segments.json")
      segments = @client.segments
      segments.size.should == 2
      segments.first.ListID.should == 'a58ee1d3039b8bec838e6d1482a8a965'
      segments.first.Name.should == 'Segment One'
    end

    should "get suppression list" do
      stub_get(@api_key, "clients/#{@client.client_id}/suppressionlist.json", "suppressionlist.json")
      sl = @client.suppressionlist
      sl.size.should == 2
      sl.first.EmailAddress.should == "subs+098u0qu0qwd@example.com"
      sl.first.Date.should == "2009-11-25 13:23:20"
      sl.first.State.should == "Suppressed"
    end

    should "get all templates" do
      stub_get(@api_key, "clients/#{@client.client_id}/templates.json", "templates.json")
      templates = @client.templates
      templates.size.should == 2
      templates.first.TemplateID.should == '5cac213cf061dd4e008de5a82b7a3621'
      templates.first.Name.should == 'Template One'
    end
    
    should "delete a client" do
      stub_delete(@api_key, "clients/#{@client.client_id}.json", nil)
      @client.delete
    end
    
  end
end
