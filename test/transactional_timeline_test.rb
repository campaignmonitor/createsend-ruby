require File.dirname(__FILE__) + '/helper'

class TransactionalTimelineTest < Test::Unit::TestCase
  multiple_contexts "authenticated_using_oauth_context", "authenticated_using_api_key_context" do
    setup do
      @client_id = "87y8d7qyw8d7yq8w7ydwqwd"
      @message_id = "ddc697c7-0788-4df3-a71a-a7cb935f00bd"
      @before_id = 'e2e270e6-fbce-11e4-97fc-a7cf717ca157'
      @after_id = 'e96fc6ca-fbce-11e4-949f-c3ccd6a68863'
      @smart_email_id = 'bb4a6ebb-663d-42a0-bdbe-60512cf30a01'
    end

    should "get statistics with the default parameters" do
      stub_get(@auth, "transactional/statistics", "tx_statistics_classic.json")
      response = CreateSend::Transactional::Timeline.new(@auth).statistics
      response.Sent.should == 1000
      response.Opened.should == 300
    end

    should "get statistics filtered by date and classic group" do
      stub_get(@auth, "transactional/statistics?from=2015-01-01&to=2015-06-30&timezone=client&group=Password%20Reset", "tx_statistics_classic.json")
      response = CreateSend::Transactional::Timeline.new(@auth).statistics(
        "from" => "2015-01-01",
        "to" => "2015-06-30",
        "timezone" => "client",
        "group" => "Password Reset"
      )
      response.Query.TimeZone.should == "(GMT+10:00) Canberra, Melbourne, Sydney"
      response.Query.Group.should == "Password Reset"
      response.Sent.should == 1000
    end

    should "get statistics filtered by date and smart email" do
      stub_get(@auth, "transactional/statistics?from=2015-01-01&to=2015-06-30&timezone=utc&smartEmailID=#{@smart_email_id}", "tx_statistics_smart.json")
      response = CreateSend::Transactional::Timeline.new(@auth).statistics(
        "from" => "2015-01-01",
        "to" => "2015-06-30",
        "timezone" => "utc",
        "smartEmailID" => "bb4a6ebb-663d-42a0-bdbe-60512cf30a01"
      )
      response.Query.TimeZone.should == "UTC"
      response.Query.SmartEmailID.should == "bb4a6ebb-663d-42a0-bdbe-60512cf30a01"
      response.Sent.should == 1000
    end

    should "get the message timeline with default parameters" do
      stub_get(@auth, "transactional/messages", "tx_messages.json")
      response = CreateSend::Transactional::Timeline.new(@auth).messages
      response.length.should == 3
      response[0].MessageID.should == "ddc697c7-0788-4df3-a71a-a7cb935f00bd"
      response[0].Status.should == "Delivered"
    end

    should "get the message timeline for a smart email" do
      stub_get(@auth, "transactional/messages?status=all&count=200&sentBeforeID=#{@before_id}&sentAfterID=#{@after_id}&smartEmailID=#{@smart_email_id}&clientID=#{@client_id}", "tx_messages_smart.json")
      response = CreateSend::Transactional::Timeline.new(@auth).messages(
        "status" => 'all',
        "count" => 200,
        "sentBeforeID" => @before_id,
        "sentAfterID" => @after_id,
        "smartEmailID" => @smart_email_id,
        "clientID" => @client_id
      )
      response.length.should == 1
      response[0].MessageID.should == "ddc697c7-0788-4df3-a71a-a7cb935f00bd"
      response[0].Status.should == "Delivered"
    end

    should "get the message timeline for a classic group" do
      stub_get(@auth, "transactional/messages?status=all&count=200&sentBeforeID=#{@before_id}&sentAfterID=#{@after_id}&group=Password%20Reset&clientID=#{@client_id}", "tx_messages_classic.json")
      response = CreateSend::Transactional::Timeline.new(@auth).messages(
        "status" => 'all',
        "count" => 200,
        "sentBeforeID" => @before_id,
        "sentAfterID" => @after_id,
        "group" => 'Password Reset',
        "clientID" => @client_id
      )
      response.length.should == 1
      response[0].Group.should == "Password Reset"
      response[0].Status.should == "Delivered"
    end

    should "get the message details" do
      stub_get(@auth, "transactional/messages/#{@message_id}", "tx_message_details.json")
      response = CreateSend::Transactional::Timeline.new(@auth).details(@message_id)
      response.TotalOpens.should == 1
      response.TotalClicks.should == 1
    end

    should "get the message details with statistics" do
      stub_get(@auth, "transactional/messages/#{@message_id}?statistics=true", "tx_message_details_with_statistics.json")
      response = CreateSend::Transactional::Timeline.new(@auth).details(@message_id, :statistics => true)
      response.Opens.length == 1
      response.Clicks.length == 1
    end

    should "resend a message" do
      stub_post(@auth, "transactional/messages/#{@message_id}/resend", "tx_send_single.json")
      response = CreateSend::Transactional::Timeline.new(@auth).resend(@message_id)
      response.length.should == 1
      response[0].MessageID.should == "0cfe150d-d507-11e4-84a7-c31e5b59881d"
      response[0].Recipient.should == "\"Bob Sacamano\" <bob@example.com>"
      response[0].Status.should == "Received"
    end

  end
end


