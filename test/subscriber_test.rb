require File.dirname(__FILE__) + '/helper'

class SubscriberTest < Test::Unit::TestCase
  multiple_contexts "authenticated_using_oauth_context", "authenticated_using_api_key_context" do
    setup do
      @list_id = "d98h2938d9283d982u3d98u88"
      @subscriber = CreateSend::Subscriber.new @auth, @list_id, "subscriber@example.com"
    end
    
    should "get a subscriber by list id and email address" do
      email = "subscriber@example.com"
      stub_get(@auth, "subscribers/#{@list_id}.json?email=#{CGI.escape(email)}", "subscriber_details.json")
      subscriber = CreateSend::Subscriber.get @auth, @list_id, email
      subscriber.EmailAddress.should == email
      subscriber.Name.should == "Subscriber One"
      subscriber.Date.should == "2010-10-25 10:28:00"
      subscriber.State.should == "Active"
      subscriber.CustomFields.size.should == 3
      subscriber.CustomFields.first.Key.should == 'website'
      subscriber.CustomFields.first.Value.should == 'http://example.com'
      subscriber.ReadsEmailWith.should == "Gmail"
    end

    should "add a subscriber without custom fields" do
      stub_post(@auth, "subscribers/#{@list_id}.json", "add_subscriber.json")
      email_address = CreateSend::Subscriber.add @auth, @list_id, "subscriber@example.com", "Subscriber", [], true
      email_address.should == "subscriber@example.com"
    end

    should "add a subscriber with custom fields" do
      stub_post(@auth, "subscribers/#{@list_id}.json", "add_subscriber.json")
      custom_fields = [ { :Key => 'website', :Value => 'http://example.com/' } ]
      email_address = CreateSend::Subscriber.add @auth, @list_id, "subscriber@example.com", "Subscriber", custom_fields, true
      email_address.should == "subscriber@example.com"
    end

    should "add a subscriber with custom fields including multi-option fields" do
      stub_post(@auth, "subscribers/#{@list_id}.json", "add_subscriber.json")
      custom_fields = [ { :Key => 'multioptionselectone', :Value => 'myoption' }, 
        { :Key => 'multioptionselectmany', :Value => 'firstoption' },
        { :Key => 'multioptionselectmany', :Value => 'secondoption' } ]
      email_address = CreateSend::Subscriber.add @auth, @list_id, "subscriber@example.com", "Subscriber", custom_fields, true
      email_address.should == "subscriber@example.com"
    end

    should "update a subscriber with custom fields" do
      email = "subscriber@example.com"
      new_email = "new_email_address@example.com"
      stub_put(@auth, "subscribers/#{@list_id}.json?email=#{CGI.escape(email)}", nil)
      custom_fields = [ { :Key => 'website', :Value => 'http://example.com/' } ]
      @subscriber.update new_email, "Subscriber", custom_fields, true
      @subscriber.email_address.should == new_email
    end

    should "update a subscriber with custom fields including the clear option" do
      email = "subscriber@example.com"
      new_email = "new_email_address@example.com"
      stub_put(@auth, "subscribers/#{@list_id}.json?email=#{CGI.escape(email)}", nil)
      custom_fields = [ { :Key => 'website', :Value => '', :Clear => true } ]
      @subscriber.update new_email, "Subscriber", custom_fields, true
      @subscriber.email_address.should == new_email
    end
    
    should "import many subscribers at once" do
      stub_post(@auth, "subscribers/#{@list_id}/import.json", "import_subscribers.json")
      subscribers = [
        { :EmailAddress => "example+1@example.com", :Name => "Example One" },
        { :EmailAddress => "example+2@example.com", :Name => "Example Two" },
        { :EmailAddress => "example+3@example.com", :Name => "Example Three" },
      ]
      import_result = CreateSend::Subscriber.import @auth, @list_id, subscribers, true
      import_result.FailureDetails.size.should == 0
      import_result.TotalUniqueEmailsSubmitted.should == 3
      import_result.TotalExistingSubscribers.should == 0
      import_result.TotalNewSubscribers.should == 3
      import_result.DuplicateEmailsInSubmission.size.should == 0
    end

    should "import many subscribers at once, and start subscription-based autoresponders" do
      stub_post(@auth, "subscribers/#{@list_id}/import.json", "import_subscribers.json")
      subscribers = [
        { :EmailAddress => "example+1@example.com", :Name => "Example One" },
        { :EmailAddress => "example+2@example.com", :Name => "Example Two" },
        { :EmailAddress => "example+3@example.com", :Name => "Example Three" },
      ]
      import_result = CreateSend::Subscriber.import @auth, @list_id, subscribers, true, true
      import_result.FailureDetails.size.should == 0
      import_result.TotalUniqueEmailsSubmitted.should == 3
      import_result.TotalExistingSubscribers.should == 0
      import_result.TotalNewSubscribers.should == 3
      import_result.DuplicateEmailsInSubmission.size.should == 0
    end

    should "import many subscribers at once with custom fields, including the clear option" do
      stub_post(@auth, "subscribers/#{@list_id}/import.json", "import_subscribers.json")
      subscribers = [
        { :EmailAddress => "example+1@example.com", :Name => "Example One", :CustomFields => [ { :Key => 'website', :Value => '', :Clear => true } ] },
        { :EmailAddress => "example+2@example.com", :Name => "Example Two", :CustomFields => [ { :Key => 'website', :Value => '', :Clear => false } ]  },
        { :EmailAddress => "example+3@example.com", :Name => "Example Three", :CustomFields => [ { :Key => 'website', :Value => '', :Clear => false } ]  },
      ]
      import_result = CreateSend::Subscriber.import @auth, @list_id, subscribers, true
      import_result.FailureDetails.size.should == 0
      import_result.TotalUniqueEmailsSubmitted.should == 3
      import_result.TotalExistingSubscribers.should == 0
      import_result.TotalNewSubscribers.should == 3
      import_result.DuplicateEmailsInSubmission.size.should == 0
    end

    should "import many subscribers at once with partial success" do
      # Stub request with 400 Bad Request as the expected response status
      stub_post(@auth, "subscribers/#{@list_id}/import.json", "import_subscribers_partial_success.json", 400)
      subscribers = [
        { :EmailAddress => "example+1@example", :Name => "Example One" },
        { :EmailAddress => "example+2@example.com", :Name => "Example Two" },
        { :EmailAddress => "example+3@example.com", :Name => "Example Three" },
      ]
      import_result = CreateSend::Subscriber.import @auth, @list_id, subscribers, true
      import_result.FailureDetails.size.should == 1
      import_result.FailureDetails.first.EmailAddress.should == "example+1@example"
      import_result.FailureDetails.first.Code.should == 1
      import_result.FailureDetails.first.Message.should == "Invalid Email Address"
      import_result.TotalUniqueEmailsSubmitted.should == 3
      import_result.TotalExistingSubscribers.should == 2
      import_result.TotalNewSubscribers.should == 0
      import_result.DuplicateEmailsInSubmission.size.should == 0
    end

    should "raise a BadRequest error if the import _completely_ fails because of a bad request" do
      # Stub request with 400 Bad Request as the expected response status
      stub_post(@auth, "subscribers/#{@list_id}/import.json", "custom_api_error.json", 400)
      subscribers = [
        { :EmailAddress => "example+1@example", :Name => "Example One" },
        { :EmailAddress => "example+2@example.com", :Name => "Example Two" },
        { :EmailAddress => "example+3@example.com", :Name => "Example Three" },
      ]
      lambda { import_result = CreateSend::Subscriber.import @auth, @list_id, subscribers, true
        }.should raise_error(CreateSend::BadRequest)
    end

    should "unsubscribe a subscriber" do
      stub_post(@auth, "subscribers/#{@subscriber.list_id}/unsubscribe.json", nil)
      @subscriber.unsubscribe
    end

    should "get a subscriber's history" do
      stub_get(@auth, "subscribers/#{@subscriber.list_id}/history.json?email=#{CGI.escape(@subscriber.email_address)}", "subscriber_history.json")
      history = @subscriber.history
      history.size.should == 1
      history.first.Name.should == "Campaign One"
      history.first.Type.should == "Campaign"
      history.first.ID.should == "fc0ce7105baeaf97f47c99be31d02a91"
      history.first.Actions.size.should == 6
      history.first.Actions.first.Event.should ==  "Open"
      history.first.Actions.first.Date.should ==  "2010-10-12 13:18:00"
      history.first.Actions.first.IPAddress.should == "192.168.126.87"
      history.first.Actions.first.Detail.should == ""
    end

    should "delete a subscriber" do
      stub_delete(@auth, "subscribers/#{@subscriber.list_id}.json?email=#{CGI.escape(@subscriber.email_address)}", nil)
      @subscriber.delete
    end
  end
end