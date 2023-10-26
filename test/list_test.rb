require File.dirname(__FILE__) + '/helper'

class ListTest < Test::Unit::TestCase
  multiple_contexts "authenticated_using_oauth_context", "authenticated_using_api_key_context" do
    setup do
      @client_id = "87y8d7qyw8d7yq8w7ydwqwd"
      @list_id = "e3c5f034d68744f7881fdccf13c2daee"
      @list = CreateSend::List.new @auth, @list_id
    end

    should "create a list without passing in unsubscribe setting" do
      stub_post(@auth, "lists/#{@client_id}.json", "create_list.json")
      list_id = CreateSend::List.create @auth, @client_id, "List One", "", false, ""
      list_id.should be == "e3c5f034d68744f7881fdccf13c2daee"
    end

    should "create a list passing in unsubscribe setting" do
      stub_post(@auth, "lists/#{@client_id}.json", "create_list.json")
      list_id = CreateSend::List.create @auth, @client_id, "List One", "", false, "", "OnlyThisList"
      list_id.should be == "e3c5f034d68744f7881fdccf13c2daee"
    end

    should "update a list without passing in unsubscribe setting" do
      stub_put(@auth, "lists/#{@list.list_id}.json", nil)
      @list.update "List One Renamed", "", false, ""
    end

    should "update a list passing in unsubscribe setting" do
      stub_put(@auth, "lists/#{@list.list_id}.json", nil)
      @list.update "List One Renamed", "", false, "", "OnlyThisList"
    end

    should "update a list passing in unsubscribe setting and suppression list options" do
      stub_put(@auth, "lists/#{@list.list_id}.json", nil)
      @list.update "List One Renamed", "", false, "", "OnlyThisList", true, true
    end

    should "delete a list" do
      stub_delete(@auth, "lists/#{@list.list_id}.json", nil)
      @list.delete
    end

    should "create a custom field" do
      stub_post(@auth, "lists/#{@list.list_id}/customfields.json", "create_custom_field.json")
      personalisation_tag = @list.create_custom_field "new date field", "Date"
      request = FakeWeb.last_request.body
      request.include?("\"FieldName\":\"new date field\"").should be == true
      request.include?("\"DataType\":\"Date\"").should be == true
      request.include?("\"Options\":[]").should be == true
      request.include?("\"VisibleInPreferenceCenter\":true").should be == true
      personalisation_tag.should be == "[newdatefield]"
    end

    should "create a custom field with options and visible_in_preference_center" do
      stub_post(@auth, "lists/#{@list.list_id}/customfields.json", "create_custom_field.json")
      options = ["one", "two"]
      personalisation_tag = @list.create_custom_field("newsletter format",
        "MultiSelectOne", options, false)
      request = FakeWeb.last_request.body
      request.include?("\"FieldName\":\"newsletter format\"").should be == true
      request.include?("\"DataType\":\"MultiSelectOne\"").should be == true
      request.include?("\"Options\":[\"one\",\"two\"]").should be == true
      request.include?("\"VisibleInPreferenceCenter\":false").should be == true
      personalisation_tag.should be == "[newdatefield]"
    end

    should "update a custom field" do
      key = "[mycustomfield]"
      stub_put(@auth, "lists/#{@list.list_id}/customfields/#{ERB::Util.url_encode(key)}.json", "update_custom_field.json")
      personalisation_tag = @list.update_custom_field key, "my renamed custom field", true
      request = FakeWeb.last_request.body
      request.include?("\"FieldName\":\"my renamed custom field\"").should be == true
      request.include?("\"VisibleInPreferenceCenter\":true").should be == true
      personalisation_tag.should be == "[myrenamedcustomfield]"
    end

    should "delete a custom field" do
      custom_field_key = "[newdatefield]"
      stub_delete(@auth, "lists/#{@list.list_id}/customfields/#{ERB::Util.url_encode(custom_field_key)}.json", nil)
      @list.delete_custom_field custom_field_key
    end
    
    should "update the options of a multi-optioned custom field" do
      custom_field_key = "[newdatefield]"
      new_options = [ "one", "two", "three" ]
      stub_put(@auth, "lists/#{@list.list_id}/customfields/#{ERB::Util.url_encode(custom_field_key)}/options.json", nil)
      @list.update_custom_field_options custom_field_key, new_options, true
    end

    should "get the details of a list" do
      stub_get(@auth, "lists/#{@list.list_id}.json", "list_details.json")
      details = @list.details
      details.ConfirmedOptIn.should be == false
      details.Title.should be == "a non-basic list :)"
      details.UnsubscribePage.should be == ""
      details.ListID.should be == "2fe4c8f0373ce320e2200596d7ef168f"
      details.ConfirmationSuccessPage.should be == ""
      details.UnsubscribeSetting.should be == "AllClientLists"
    end

    should "get the custom fields for a list" do
      stub_get(@auth, "lists/#{@list.list_id}/customfields.json", "custom_fields.json")
      cfs = @list.custom_fields
      cfs.size.should be == 3
      cfs.first.FieldName.should be == "website"
      cfs.first.Key.should be == "[website]"
      cfs.first.DataType.should be == "Text"
      cfs.first.FieldOptions.should be == []
      cfs.first.VisibleInPreferenceCenter.should be == true
    end

    should "get the segments for a list" do
      stub_get(@auth, "lists/#{@list.list_id}/segments.json", "segments.json")
      segments = @list.segments
      segments.size.should be == 2
      segments.first.ListID.should be == 'a58ee1d3039b8bec838e6d1482a8a965'
      segments.first.SegmentID.should be == '46aa5e01fd43381863d4e42cf277d3a9'
      segments.first.Title.should be == 'Segment One'
    end
    
    should "get the stats for a list" do
      stub_get(@auth, "lists/#{@list.list_id}/stats.json", "list_stats.json")
      stats = @list.stats
      stats.TotalActiveSubscribers.should be == 6
      stats.TotalUnsubscribes.should be == 2
      stats.TotalDeleted.should be == 0
      stats.TotalBounces.should be == 0
    end
    
    should "get the active subscribers for a list" do
      min_date = "2010-01-01"
      stub_get(@auth, "lists/#{@list.list_id}/active.json?pagesize=1000&orderfield=email&page=1&orderdirection=asc&date=#{ERB::Util.url_encode(min_date)}&includetrackingpreference=false",
        "active_subscribers.json")
      res = @list.active min_date
      res.ResultsOrderedBy.should be == "email"
      res.OrderDirection.should be == "asc"
      res.PageNumber.should be == 1
      res.PageSize.should be == 1000
      res.RecordsOnThisPage.should be == 5
      res.TotalNumberOfRecords.should be == 5
      res.NumberOfPages.should be == 1
      res.Results.size.should be == 5
      res.Results.first.EmailAddress.should be == "subs+7t8787Y@example.com"
      res.Results.first.Name.should be =="Person One"
      res.Results.first.Date.should be == "2010-10-25 10:28:00"
      res.Results.first.ListJoinedDate.should be == "2010-10-25 10:28:00"
      res.Results.first.State.should be == "Active"
      res.Results.first.CustomFields.size.should be == 5
      res.Results.first.CustomFields[0].Key.should be == "website"
      res.Results.first.CustomFields[0].Value.should be == "http://example.com"
      res.Results.first.CustomFields[1].Key.should be == "multi select field"
      res.Results.first.CustomFields[1].Value.should be == "option one"
      res.Results.first.CustomFields[2].Key.should be == "multi select field"
      res.Results.first.CustomFields[2].Value.should be == "option two"
      res.Results.first.ReadsEmailWith.should be == "Gmail"
    end

    should "get the unconfirmed subscribers for a list" do
      min_date = "2010-01-01"
      stub_get(@auth, "lists/#{@list.list_id}/unconfirmed.json?pagesize=1000&orderfield=email&page=1&orderdirection=asc&date=#{ERB::Util.url_encode(min_date)}&includetrackingpreference=true",
        "unconfirmed_subscribers.json")
      res = @list.unconfirmed(min_date, 1, 1000, "email", "asc", true)
      res.ResultsOrderedBy.should be == "email"
      res.OrderDirection.should be == "asc"
      res.PageNumber.should be == 1
      res.PageSize.should be == 1000
      res.RecordsOnThisPage.should be == 2
      res.TotalNumberOfRecords.should be == 2
      res.NumberOfPages.should be == 1
      res.Results.size.should be == 2
      res.Results.first.EmailAddress.should be == "subs+7t8787Y@example.com"
      res.Results.first.Name.should be =="Unconfirmed One"
      res.Results.first.Date.should be =="2010-10-25 10:28:00"
      res.Results.first.ListJoinedDate.should be =="2010-10-25 10:28:00"
      res.Results.first.State.should be == "Unconfirmed"
      res.Results.first.ConsentToTrack.should be == "Yes"
      res.Results.first.ConsentToSendSms.should == "No"
    end

    should "get the unsubscribed subscribers for a list" do
      min_date = "2010-01-01"
      stub_get(@auth, "lists/#{@list.list_id}/unsubscribed.json?pagesize=1000&orderfield=email&page=1&orderdirection=asc&date=#{ERB::Util.url_encode(min_date)}&includetrackingpreference=false",
        "unsubscribed_subscribers.json")
      res = @list.unsubscribed min_date
      res.ResultsOrderedBy.should be == "email"
      res.OrderDirection.should be == "asc"
      res.PageNumber.should be == 1
      res.PageSize.should be == 1000
      res.RecordsOnThisPage.should be == 5
      res.TotalNumberOfRecords.should be == 5
      res.NumberOfPages.should be == 1
      res.Results.size.should be == 5
      res.Results.first.EmailAddress.should be == "subscriber@example.com"
      res.Results.first.Name.should be == "Unsub One"
      res.Results.first.Date.should be == "2010-10-25 13:11:00"
      res.Results.first.ListJoinedDate.should be == "2010-10-25 13:11:00"
      res.Results.first.State.should be == "Unsubscribed"
      res.Results.first.CustomFields.size.should be == 0
      res.Results.first.ReadsEmailWith.should be == "Gmail"
    end

    should "get the deleted subscribers for a list" do
      min_date = "2010-01-01"
      stub_get(@auth, "lists/#{@list.list_id}/deleted.json?pagesize=1000&orderfield=email&page=1&orderdirection=asc&date=#{ERB::Util.url_encode(min_date)}&includetrackingpreference=false",
        "deleted_subscribers.json")
      res = @list.deleted min_date
      res.ResultsOrderedBy.should be == "email"
      res.OrderDirection.should be == "asc"
      res.PageNumber.should be == 1
      res.PageSize.should be == 1000
      res.RecordsOnThisPage.should be == 5
      res.TotalNumberOfRecords.should be == 5
      res.NumberOfPages.should be == 1
      res.Results.size.should be == 5
      res.Results.first.EmailAddress.should be == "subscriber@example.com"
      res.Results.first.Name.should be == "Deleted One"
      res.Results.first.Date.should be == "2010-10-25 13:11:00"
      res.Results.first.ListJoinedDate.should be == "2010-10-25 13:11:00"
      res.Results.first.State.should be == "Deleted"
      res.Results.first.CustomFields.size.should be == 0
      res.Results.first.ReadsEmailWith.should be == "Gmail"
    end

    should "get the bounced subscribers for a list" do
      min_date = "2010-01-01"
      stub_get(@auth, "lists/#{@list.list_id}/bounced.json?pagesize=1000&orderfield=email&page=1&orderdirection=asc&date=#{ERB::Util.url_encode(min_date)}&includetrackingpreference=false",
        "bounced_subscribers.json")
      res = @list.bounced min_date
      res.ResultsOrderedBy.should be == "email"
      res.OrderDirection.should be == "asc"
      res.PageNumber.should be == 1
      res.PageSize.should be == 1000
      res.RecordsOnThisPage.should be == 1
      res.TotalNumberOfRecords.should be == 1
      res.NumberOfPages.should be == 1
      res.Results.size.should be == 1
      res.Results.first.EmailAddress.should be == "bouncedsubscriber@example.com"
      res.Results.first.Name.should be == "Bounced One"
      res.Results.first.Date.should be == "2010-10-25 13:11:00"
      res.Results.first.ListJoinedDate.should be == "2010-10-25 13:11:00"
      res.Results.first.State.should be == "Bounced"
      res.Results.first.CustomFields.size.should be == 0
      res.Results.first.ReadsEmailWith.should be == ""
    end

    should "get the webhooks for a list" do
      stub_get(@auth, "lists/#{@list.list_id}/webhooks.json", "list_webhooks.json")
      hooks = @list.webhooks
      hooks.size.should be == 2
      hooks.first.WebhookID.should be == "943678317049bc13"
      hooks.first.Events.size.should be == 1
      hooks.first.Events.first.should be == "Deactivate"
      hooks.first.Url.should be == "http://www.postbin.org/d9w8ud9wud9w"
      hooks.first.Status.should be == "Active"
      hooks.first.PayloadFormat.should be == "Json"
    end

    should "create a webhook for a list" do
      stub_post(@auth, "lists/#{@list.list_id}/webhooks.json", "create_list_webhook.json")
      webhook_id = @list.create_webhook ["Unsubscribe", "Spam"], "http://example.com/unsub", "json"
      webhook_id.should be == "6a783d359bd44ef62c6ca0d3eda4412a"
    end
    
    should "test a webhook for a list" do
      webhook_id = "jiuweoiwueoiwueowiueo"
      stub_get(@auth, "lists/#{@list.list_id}/webhooks/#{webhook_id}/test.json", nil)
      @list.test_webhook webhook_id
    end

    should "delete a webhook for a list" do
      webhook_id = "jiuweoiwueoiwueowiueo"
      stub_delete(@auth, "lists/#{@list.list_id}/webhooks/#{webhook_id}.json", nil)
      @list.delete_webhook webhook_id
    end
    
    should "activate a webhook for a list" do
      webhook_id = "jiuweoiwueoiwueowiueo"
      stub_put(@auth, "lists/#{@list.list_id}/webhooks/#{webhook_id}/activate.json", nil)
      @list.activate_webhook webhook_id
    end

    should "de-activate a webhook for a list" do
      webhook_id = "jiuweoiwueoiwueowiueo"
      stub_put(@auth, "lists/#{@list.list_id}/webhooks/#{webhook_id}/deactivate.json", nil)
      @list.deactivate_webhook webhook_id
    end
  end
end