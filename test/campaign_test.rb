require File.dirname(__FILE__) + '/helper'

class ClientTest < Test::Unit::TestCase
  context "when an api caller is authenticated" do
    setup do
      @api_key = '123123123123123123123'
      @base_uri = 'http://api.createsend.com/api/v3'
      @cs = CreateSend.new(:api_key => @api_key, :base_uri => @base_uri)
      @campaign = Campaign.new(:campaign_id => '787y87y87y87y87y87y87')
    end

    should "create a campaign" do
      client_id = '87y8d7qyw8d7yq8w7ydwqwd'
      stub_post(@api_key, "campaigns/#{client_id}.json", "create_campaign.json")
      campaign_id = Campaign.create client_id, "subject", "name", "g'day", "good.day@example.com", "good.day@example.com", 
      "http://example.com/campaign.html", "http://example.com/campaign.txt", [ '7y12989e82ue98u2e', 'dh9w89q8w98wudwd989' ], []
      campaign_id.should == "787y87y87y87y87y87y87"
    end
    
    
    
  end
end