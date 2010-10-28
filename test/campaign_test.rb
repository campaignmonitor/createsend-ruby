require File.dirname(__FILE__) + '/helper'

class CampaignTest < Test::Unit::TestCase
  context "when an api caller is authenticated" do
    setup do
      @api_key = '123123123123123123123'
      CreateSend.api_key @api_key
      @campaign = Campaign.new(:campaign_id => '787y87y87y87y87y87y87')
    end

    should "create a campaign" do
      client_id = '87y8d7qyw8d7yq8w7ydwqwd'
      stub_post(@api_key, "campaigns/#{client_id}.json", "create_campaign.json")
      campaign_id = Campaign.create client_id, "subject", "name", "g'day", "good.day@example.com", "good.day@example.com", 
      "http://example.com/campaign.html", "http://example.com/campaign.txt", [ '7y12989e82ue98u2e', 'dh9w89q8w98wudwd989' ], []
      campaign_id.should == "787y87y87y87y87y87y87"
    end
    
    should "send a campaign" do
      stub_post(@api_key, "campaigns/#{@campaign.campaign_id}/send.json", nil)
      @campaign.send "confirmation@example.com"
    end
    
    should "delete a campaign" do
      stub_delete(@api_key, "campaigns/#{@campaign.campaign_id}.json", nil)
      @campaign.delete
    end
    
    should "get the summary for a campaign" do
      stub_get(@api_key, "campaigns/#{@campaign.campaign_id}/summary.json", "campaign_summary.json")
      summary = @campaign.summary
      summary.Recipients.should == 5
      summary.TotalOpened.should == 10
      summary.Clicks.should == 0
      summary.Unsubscribed.should == 0
      summary.Bounced.should == 0
      summary.UniqueOpened.should == 5
      summary.WebVersionURL.should == "http://clientone.createsend.com/t/ViewEmail/r/3A433FC72FFE3B8B/C67FD2F38AC4859C/"
    end
    
    should "get the lists for a campaign" do
      stub_get(@api_key, "campaigns/#{@campaign.campaign_id}/lists.json", "campaign_lists.json")
      lists = @campaign.lists
      lists.size.should == 2
      lists.first.Name.should == "List One"
      lists.first.ListID.should == "a58ee1d3039b8bec838e6d1482a8a965"
    end

    # TODO: Add this test once segments has been implemented
    # should "get the segments for a campaign" do
    # end
    
    should "get the opens for a campaign" do
      min_date = "2010-01-01"
      stub_get(@api_key, "campaigns/#{@campaign.campaign_id}/opens.json?date=#{CGI.escape(min_date)}", "campaign_opens.json")
      opens = @campaign.opens min_date
      opens.size.should == 5
      opens.first.EmailAddress.should == "subs+6576576576@example.com"
      opens.first.ListID.should == "512a3bc577a58fdf689c654329b50fa0"
      opens.first.Date.should == "2010-10-11 08:29:00"
      opens.first.IPAddress.should == "192.168.126.87"
    end

    should "get the subscriber clicks for a campaign" do
      min_date = "2010-01-01"
      stub_get(@api_key, "campaigns/#{@campaign.campaign_id}/clicks.json?date=#{CGI.escape(min_date)}", "campaign_clicks.json")
      clicks = @campaign.clicks min_date
      clicks.size.should == 3
      clicks.first.EmailAddress.should == "subs+6576576576@example.com"
      clicks.first.URL.should == "http://video.google.com.au/?hl=en&tab=wv"
      clicks.first.ListID.should == "512a3bc577a58fdf689c654329b50fa0"
      clicks.first.Date.should == "2010-10-11 08:29:00"
      clicks.first.IPAddress.should == "192.168.126.87"
    end
    
    should "get the unsubscribes for a campaign" do
      min_date = "2010-01-01"
      stub_get(@api_key, "campaigns/#{@campaign.campaign_id}/unsubscribes.json?date=#{CGI.escape(min_date)}", "campaign_unsubscribes.json")
      unsubscribes = @campaign.unsubscribes min_date
      unsubscribes.size.should == 1
      unsubscribes.first.EmailAddress.should == "subs+6576576576@example.com"
      unsubscribes.first.ListID.should == "512a3bc577a58fdf689c654329b50fa0"
      unsubscribes.first.Date.should == "2010-10-11 08:29:00"
      unsubscribes.first.IPAddress.should == "192.168.126.87"
    end

    should "get the bounces for a campaign" do
      stub_get(@api_key, "campaigns/#{@campaign.campaign_id}/bounces.json", "campaign_bounces.json")
      bounces = @campaign.bounces
      bounces.size.should == 2
      bounces.first.EmailAddress.should == "asdf@softbouncemyemail.com"
      bounces.first.ListID.should == "654523a5855b4a440bae3fb295641546"
      bounces.first.BounceType.should == "Soft"
      bounces.first.Date.should == "2010-07-02 16:46:00"
      bounces.first.Reason.should == "Bounce - But No Email Address Returned "
    end
  end
end