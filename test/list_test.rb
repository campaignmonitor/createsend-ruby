require File.dirname(__FILE__) + '/helper'

class ListTest < Test::Unit::TestCase
  context "when an api caller is authenticated" do
    setup do
      @api_key = '123123123123123123123'
      @client_id = "87y8d7qyw8d7yq8w7ydwqwd"
      @list_id = "e3c5f034d68744f7881fdccf13c2daee"
      @list = CreateSend::List.new @list_id, @api_key
    end

    should "create a list" do
      stub_post(@api_key, "lists/#{@client_id}.json", "create_list.json", @api_key)
      list_id = CreateSend::List.create @client_id, "List One", "", false, "", @api_key
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
    
    should "update the options of a multi-optioned custom field" do
      custom_field_key = "[newdatefield]"
      new_options = [ "one", "two", "three" ]
      stub_put(@api_key, "lists/#{@list.list_id}/customfields/#{CGI.escape(custom_field_key)}/options.json", nil)
      @list.update_custom_field_options custom_field_key, new_options, true
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
      stub_get(@api_key, "lists/#{@list.list_id}/active.json?pagesize=1000&orderfield=email&page=1&orderdirection=asc&date=#{CGI.escape(min_date)}",
        "active_subscribers.json")
      res = @list.active min_date
      res.ResultsOrderedBy.should == "email"
      res.OrderDirection.should == "asc"
      res.PageNumber.should == 1
      res.PageSize.should == 1000
      res.RecordsOnThisPage.should == 5
      res.TotalNumberOfRecords.should == 5
      res.NumberOfPages.should == 1
      res.Results.size.should == 5
      res.Results.first.EmailAddress.should == "subs+7t8787Y@example.com"
      res.Results.first.Name.should =="Person One"
      res.Results.first.Date.should == "2010-10-25 10:28:00"
      res.Results.first.State.should == "Active"
      res.Results.first.CustomFields.size.should == 3
    end
    
    should "get the unsubscribed subscribers for a list" do
      min_date = "2010-01-01"
      stub_get(@api_key, "lists/#{@list.list_id}/unsubscribed.json?pagesize=1000&orderfield=email&page=1&orderdirection=asc&date=#{CGI.escape(min_date)}", 
        "unsubscribed_subscribers.json")
      res = @list.unsubscribed min_date
      res.ResultsOrderedBy.should == "email"
      res.OrderDirection.should == "asc"
      res.PageNumber.should == 1
      res.PageSize.should == 1000
      res.RecordsOnThisPage.should == 5
      res.TotalNumberOfRecords.should == 5
      res.NumberOfPages.should == 1
      res.Results.size.should == 5
      res.Results.first.EmailAddress.should == "subscriber@example.com"
      res.Results.first.Name.should == "Unsub One"
      res.Results.first.Date.should == "2010-10-25 13:11:00"
      res.Results.first.State.should == "Unsubscribed"
      res.Results.first.CustomFields.size.should == 0
    end

    should "get the deleted subscribers for a list" do
      min_date = "2010-01-01"
      stub_get(@api_key, "lists/#{@list.list_id}/deleted.json?pagesize=1000&orderfield=email&page=1&orderdirection=asc&date=#{CGI.escape(min_date)}", 
        "deleted_subscribers.json")
      res = @list.deleted min_date
      res.ResultsOrderedBy.should == "email"
      res.OrderDirection.should == "asc"
      res.PageNumber.should == 1
      res.PageSize.should == 1000
      res.RecordsOnThisPage.should == 5
      res.TotalNumberOfRecords.should == 5
      res.NumberOfPages.should == 1
      res.Results.size.should == 5
      res.Results.first.EmailAddress.should == "subscriber@example.com"
      res.Results.first.Name.should == "Deleted One"
      res.Results.first.Date.should == "2010-10-25 13:11:00"
      res.Results.first.State.should == "Deleted"
      res.Results.first.CustomFields.size.should == 0
    end

    should "get the bounced subscribers for a list" do
      min_date = "2010-01-01"
      stub_get(@api_key, "lists/#{@list.list_id}/bounced.json?pagesize=1000&orderfield=email&page=1&orderdirection=asc&date=#{CGI.escape(min_date)}",
        "bounced_subscribers.json")
      res = @list.bounced min_date
      res.ResultsOrderedBy.should == "email"
      res.OrderDirection.should == "asc"
      res.PageNumber.should == 1
      res.PageSize.should == 1000
      res.RecordsOnThisPage.should == 1
      res.TotalNumberOfRecords.should == 1
      res.NumberOfPages.should == 1
      res.Results.size.should == 1
      res.Results.first.EmailAddress.should == "bouncedsubscriber@example.com"
      res.Results.first.Name.should == "Bounced One"
      res.Results.first.Date.should == "2010-10-25 13:11:00"
      res.Results.first.State.should == "Bounced"
      res.Results.first.CustomFields.size.should == 0
    end

    should "get the webhooks for a list" do
      stub_get(@api_key, "lists/#{@list.list_id}/webhooks.json", "list_webhooks.json")
      hooks = @list.webhooks
      hooks.size.should == 2
      hooks.first.WebhookID.should == "943678317049bc13"
      hooks.first.Events.size.should == 1
      hooks.first.Events.first.should == "Deactivate"
      hooks.first.Url.should == "http://www.postbin.org/d9w8ud9wud9w"
      hooks.first.Status.should == "Active"
      hooks.first.PayloadFormat.should == "Json"
    end

    should "create a webhook for a list" do
      stub_post(@api_key, "lists/#{@list.list_id}/webhooks.json", "create_list_webhook.json")
      webhook_id = @list.create_webhook ["Unsubscribe", "Spam"], "http://example.com/unsub", "json"
      webhook_id.should == "6a783d359bd44ef62c6ca0d3eda4412a"
    end
    
    should "test a webhook for a list" do
      webhook_id = "jiuweoiwueoiwueowiueo"
      stub_get(@api_key, "lists/#{@list.list_id}/webhooks/#{webhook_id}/test.json", nil)
      @list.test_webhook webhook_id
    end

    should "delete a webhook for a list" do
      webhook_id = "jiuweoiwueoiwueowiueo"
      stub_delete(@api_key, "lists/#{@list.list_id}/webhooks/#{webhook_id}.json", nil)
      @list.delete_webhook webhook_id
    end
    
    should "activate a webhook for a list" do
      webhook_id = "jiuweoiwueoiwueowiueo"
      stub_put(@api_key, "lists/#{@list.list_id}/webhooks/#{webhook_id}/activate.json", nil)
      @list.activate_webhook webhook_id
    end

    should "de-activate a webhook for a list" do
      webhook_id = "jiuweoiwueoiwueowiueo"
      stub_put(@api_key, "lists/#{@list.list_id}/webhooks/#{webhook_id}/deactivate.json", nil)
      @list.deactivate_webhook webhook_id
    end
  end
end