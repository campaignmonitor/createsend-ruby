require File.dirname(__FILE__) + '/helper'

class CampaignTest < Test::Unit::TestCase
  context "when an api caller is authenticated" do
    setup do
      @api_key = '123123123123123123123'
      @campaign = CreateSend::Campaign.new('787y87y87y87y87y87y87', @api_key)
    end

    should "create a campaign" do
      client_id = '87y8d7qyw8d7yq8w7ydwqwd'
      stub_post(@api_key, "campaigns/#{client_id}.json", "create_campaign.json")
      campaign_id = CreateSend::Campaign.create client_id, "subject", "name", "g'day", "good.day@example.com", "good.day@example.com", 
      "http://example.com/campaign.html", "http://example.com/campaign.txt", [ '7y12989e82ue98u2e', 'dh9w89q8w98wudwd989' ],
      [ 'y78q9w8d9w8ud9q8uw', 'djw98quw9duqw98uwd98' ], @api_key
      campaign_id.should == "787y87y87y87y87y87y87"
    end

    should "send a preview of a draft campaign" do
      stub_post(@api_key, "campaigns/#{@campaign.campaign_id}/sendpreview.json", nil)
      @campaign.send_preview [ "test+89898u9@example.com", "test+787y8y7y8@example.com" ], "random"
    end

    should "send a campaign" do
      stub_post(@api_key, "campaigns/#{@campaign.campaign_id}/send.json", nil)
      @campaign.send "confirmation@example.com"
    end

    should "unschedule a campaign" do
      stub_post(@api_key, "campaigns/#{@campaign.campaign_id}/unschedule.json", nil)
      @campaign.unschedule
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
      summary.Mentions.should == 23
      summary.Forwards.should == 11
      summary.Likes.should == 32
      summary.WebVersionURL.should == "http://createsend.com/t/r-3A433FC72FFE3B8B"
    end
    
    should "get the lists and segments for a campaign" do
      stub_get(@api_key, "campaigns/#{@campaign.campaign_id}/listsandsegments.json", "campaign_listsandsegments.json")
      ls = @campaign.lists_and_segments
      ls.Lists.size.should == 1
      ls.Segments.size.should == 1
      ls.Lists.first.Name.should == "List One"
      ls.Lists.first.ListID.should == "a58ee1d3039b8bec838e6d1482a8a965"
      ls.Segments.first.Title.should == "Segment for campaign"
      ls.Segments.first.ListID.should == "2bea949d0bf96148c3e6a209d2e82060"
      ls.Segments.first.SegmentID.should == "dba84a225d5ce3d19105d7257baac46f"
    end

    should "get the recipients for a campaign" do
      stub_get(@api_key, "campaigns/#{@campaign.campaign_id}/recipients.json?pagesize=20&orderfield=email&page=1&orderdirection=asc", "campaign_recipients.json")
      res = @campaign.recipients page=1, page_size=20
      res.ResultsOrderedBy.should == "email"
      res.OrderDirection.should == "asc"
      res.PageNumber.should == 1
      res.PageSize.should == 20
      res.RecordsOnThisPage.should == 20
      res.TotalNumberOfRecords.should == 2200
      res.NumberOfPages.should == 110
      res.Results.size.should == 20
      res.Results.first.EmailAddress.should == "subs+6g76t7t0@example.com"
      res.Results.first.ListID.should == "a994a3caf1328a16af9a69a730eaa706"
    end
    
    should "get the opens for a campaign" do
      min_date = "2010-01-01"
      stub_get(@api_key, "campaigns/#{@campaign.campaign_id}/opens.json?page=1&pagesize=1000&orderfield=date&orderdirection=asc&date=#{CGI.escape(min_date)}", "campaign_opens.json")
      opens = @campaign.opens min_date
      opens.Results.size.should == 5
      opens.Results.first.EmailAddress.should == "subs+6576576576@example.com"
      opens.Results.first.ListID.should == "512a3bc577a58fdf689c654329b50fa0"
      opens.Results.first.Date.should == "2010-10-11 08:29:00"
      opens.Results.first.IPAddress.should == "192.168.126.87"
      opens.ResultsOrderedBy.should == "date"
      opens.OrderDirection.should == "asc"
      opens.PageNumber.should == 1
      opens.PageSize.should == 1000
      opens.RecordsOnThisPage.should == 5
      opens.TotalNumberOfRecords.should == 5
      opens.NumberOfPages.should == 1
    end

    should "get the subscriber clicks for a campaign" do
      min_date = "2010-01-01"
      stub_get(@api_key, "campaigns/#{@campaign.campaign_id}/clicks.json?page=1&pagesize=1000&orderfield=date&orderdirection=asc&date=#{CGI.escape(min_date)}", "campaign_clicks.json")
      clicks = @campaign.clicks min_date
      clicks.Results.size.should == 3
      clicks.Results.first.EmailAddress.should == "subs+6576576576@example.com"
      clicks.Results.first.URL.should == "http://video.google.com.au/?hl=en&tab=wv"
      clicks.Results.first.ListID.should == "512a3bc577a58fdf689c654329b50fa0"
      clicks.Results.first.Date.should == "2010-10-11 08:29:00"
      clicks.Results.first.IPAddress.should == "192.168.126.87"
      clicks.ResultsOrderedBy.should == "date"
      clicks.OrderDirection.should == "asc"
      clicks.PageNumber.should == 1
      clicks.PageSize.should == 1000
      clicks.RecordsOnThisPage.should == 3
      clicks.TotalNumberOfRecords.should == 3
      clicks.NumberOfPages.should == 1
    end
    
    should "get the unsubscribes for a campaign" do
      min_date = "2010-01-01"
      stub_get(@api_key, "campaigns/#{@campaign.campaign_id}/unsubscribes.json?page=1&pagesize=1000&orderfield=date&orderdirection=asc&date=#{CGI.escape(min_date)}", "campaign_unsubscribes.json")
      unsubscribes = @campaign.unsubscribes min_date
      unsubscribes.Results.size.should == 1
      unsubscribes.Results.first.EmailAddress.should == "subs+6576576576@example.com"
      unsubscribes.Results.first.ListID.should == "512a3bc577a58fdf689c654329b50fa0"
      unsubscribes.Results.first.Date.should == "2010-10-11 08:29:00"
      unsubscribes.Results.first.IPAddress.should == "192.168.126.87"
      unsubscribes.ResultsOrderedBy.should == "date"
      unsubscribes.OrderDirection.should == "asc"
      unsubscribes.PageNumber.should == 1
      unsubscribes.PageSize.should == 1000
      unsubscribes.RecordsOnThisPage.should == 1
      unsubscribes.TotalNumberOfRecords.should == 1
      unsubscribes.NumberOfPages.should == 1
    end

    should "get the bounces for a campaign" do
      min_date = "2010-01-01"
      stub_get(@api_key, "campaigns/#{@campaign.campaign_id}/bounces.json?page=1&pagesize=1000&orderfield=date&orderdirection=asc&date=#{CGI.escape(min_date)}", "campaign_bounces.json")
      bounces = @campaign.bounces min_date
      bounces.Results.size.should == 2
      bounces.Results.first.EmailAddress.should == "asdf@softbouncemyemail.com"
      bounces.Results.first.ListID.should == "654523a5855b4a440bae3fb295641546"
      bounces.Results.first.BounceType.should == "Soft"
      bounces.Results.first.Date.should == "2010-07-02 16:46:00"
      bounces.Results.first.Reason.should == "Bounce - But No Email Address Returned "
      bounces.ResultsOrderedBy.should == "date"
      bounces.OrderDirection.should == "asc"
      bounces.PageNumber.should == 1
      bounces.PageSize.should == 1000
      bounces.RecordsOnThisPage.should == 2
      bounces.TotalNumberOfRecords.should == 2
      bounces.NumberOfPages.should == 1
    end
  end
end