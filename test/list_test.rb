require File.dirname(__FILE__) + '/helper'

class ListTest < Test::Unit::TestCase
  context "when an api caller is authenticated" do
    setup do
      @api_key = '123123123123123123123'
      CreateSend.api_key @api_key
      @client_id = "87y8d7qyw8d7yq8w7ydwqwd"
      @list_id = "e3c5f034d68744f7881fdccf13c2daee"
      @list = List.new @list_id
    end

    should "create a list" do
      stub_post(@api_key, "lists/#{@client_id}.json", "create_list.json")
      list_id = List.create @client_id, "List One", "", false, ""
      list_id.should == "e3c5f034d68744f7881fdccf13c2daee"
    end
    
    should "update a list" do
      stub_put(@api_key, "lists/#{@list.list_id}.json", nil)
      @list.update "List One Renamed", "", false, ""
    end
    
    should "delete a list" do
      stub_delete(@api_key, "lists/#{@list.list_id}.json", nil)
      @list.delete
    end

    should "create a custom field" do
      stub_post(@api_key, "lists/#{@list.list_id}/customfields.json", "create_custom_field.json")
      personalisation_tag = @list.create_custom_field "new date field", "Date"
      personalisation_tag.should == "[newdatefield]"
    end

    should "delete a custom field" do
      custom_field_key = "[newdatefield]"
      stub_delete(@api_key, "lists/#{@list.list_id}/customfields/#{CGI.escape(custom_field_key)}.json", nil)
      @list.delete_custom_field custom_field_key
    end

    should "get the details of a list" do
      stub_get(@api_key, "lists/#{@list.list_id}.json", "list_details.json")
      details = @list.details
      details.ConfirmedOptIn.should == false
      details.Title.should == "a non-basic list :)"
      details.UnsubscribePage.should == ""
      details.ListID.should == "2fe4c8f0373ce320e2200596d7ef168f"
      details.ConfirmationSuccessPage.should == ""
    end

    should "get the custom fields for a list" do
      stub_get(@api_key, "lists/#{@list.list_id}/customfields.json", "custom_fields.json")
      cfs = @list.custom_fields
      cfs.size.should == 3
      cfs.first.FieldName.should == "website"
      cfs.first.Key.should == "[website]"
      cfs.first.DataType.should == "Text"
      cfs.first.FieldOptions.should == []
    end

    should "get the segments for a list" do
      stub_get(@api_key, "lists/#{@list.list_id}/segments.json", "segments.json")
      segments = @list.segments
      segments.size.should == 2
      segments.first.ListID.should == 'a58ee1d3039b8bec838e6d1482a8a965'
      segments.first.SegmentID.should == '46aa5e01fd43381863d4e42cf277d3a9'
      segments.first.Title.should == 'Segment One'
    end

    should "get the stats for a list" do
      stub_get(@api_key, "lists/#{@list.list_id}/stats.json", "list_stats.json")
      stats = @list.stats
      stats.TotalActiveSubscribers.should == 6
      stats.TotalUnsubscribes.should == 2
      stats.TotalDeleted.should == 0
      stats.TotalBounces.should == 0
    end
    
    should "get the active subscribers for a list" do
      min_date = "2010-01-01"
      stub_get(@api_key, "lists/#{@list.list_id}/active.json?date=#{CGI.escape(min_date)}", "active_subscribers.json")
      active = @list.active min_date
      active.size.should == 6
      active.first.EmailAddress.should == "subs+7t8787Y@example.com"
      active.first.Name.should == "Subscriber One"
      active.first.Date.should == "2010-10-25 10:28:00"
      active.first.State.should == "Active"
      active.first.CustomFields.size.should == 3
    end
    
    should "get the unsubscribed subscribers for a list" do
      min_date = "2010-01-01"
      stub_get(@api_key, "lists/#{@list.list_id}/unsubscribed.json?date=#{CGI.escape(min_date)}", "unsubscribed_subscribers.json")
      unsub = @list.unsubscribed min_date
      unsub.size.should == 2
      unsub.first.EmailAddress.should == "subscriber@example.com"
      unsub.first.Name.should == "Unsub One"
      unsub.first.Date.should == "2010-10-25 13:11:00"
      unsub.first.State.should == "Unsubscribed"
      unsub.first.CustomFields.size.should == 0
    end

    should "get the bounced subscribers for a list" do
      min_date = "2010-01-01"
      stub_get(@api_key, "lists/#{@list.list_id}/bounced.json?date=#{CGI.escape(min_date)}", "bounced_subscribers.json")
      bounced = @list.bounced min_date
      bounced.size.should == 1
      bounced.first.EmailAddress.should == "bouncedsubscriber@example.com"
      bounced.first.Name.should == "Bounced One"
      bounced.first.Date.should == "2010-10-25 13:11:00"
      bounced.first.State.should == "Bounced"
      bounced.first.CustomFields.size.should == 0
    end

  end
end