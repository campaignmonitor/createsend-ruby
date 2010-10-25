require File.dirname(__FILE__) + '/helper'

class SubscriberTest < Test::Unit::TestCase
  context "when an api caller is authenticated" do
    setup do
      @api_key = '123123123123123123123'
      @base_uri = 'http://api.createsend.com/api/v3'
      @cs = CreateSend.new(:api_key => @api_key, :base_uri => @base_uri)
      @list_id = "d98h2938d9283d982u3d98u88"
    end
    
    should "get a subscriber by list id and email address" do
      email = "subscriber@example.com"
      stub_get(@api_key, "subscribers/#{@list_id}.json?email=#{CGI.escape(email)}", "subscriber_details.json")
      subscriber = Subscriber.get @list_id, email
      subscriber.EmailAddress.should == email
      subscriber.Name.should == "Subscriber One"
      subscriber.Date.should == "2010-10-25 10:28:00"
      subscriber.State.should == "Active"
      subscriber.CustomFields.size.should == 3
      subscriber.CustomFields.first.Key.should == 'website'
      subscriber.CustomFields.first.Value.should == 'http://example.com'
    end

  end
end