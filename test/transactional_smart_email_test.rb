require File.dirname(__FILE__) + '/helper'

class TransactionalSmartEmailTest < Test::Unit::TestCase
  multiple_contexts "authenticated_using_oauth_context", "authenticated_using_api_key_context" do
    setup do
      @client_id = "87y8d7qyw8d7yq8w7ydwqwd"
      @smart_email_id = "bcf40510-f968-11e4-ab73-bf67677cc1f4"
      @email = CreateSend::Transactional::SmartEmail.new @auth, @smart_email_id
    end

    should "get the list of smart emails" do
      stub_get(@auth, "transactional/smartemail", "tx_smartemails.json")
      response = CreateSend::Transactional::SmartEmail.list(@auth)
      response.length.should == 2
      response[0].ID.should == "1e654df2-f484-11e4-970c-6c4008bc7468"
      response[0].Name.should == "Welcome email"
      response[0].Status.should == "Active"
    end

    should "get the list of active smart emails using a client ID" do
      stub_get(@auth, "transactional/smartemail?status=active&client=#{@client_id}", "tx_smartemails.json")
      response = CreateSend::Transactional::SmartEmail.list(@auth, { :client => @client_id, :status => 'active'} )
      response.length.should == 2
      response[0].ID.should == "1e654df2-f484-11e4-970c-6c4008bc7468"
      response[0].Name.should == "Welcome email"
      response[0].Status.should == "Active"
    end

    should "get the details of smart email" do
      stub_get(@auth, "transactional/smartemail/#{@smart_email_id}", "tx_smartemail_details.json")
      response = CreateSend::Transactional::SmartEmail.new(@auth, @smart_email_id).details
      response.Name.should == "Reset Password"
      response.Status.should == "active"
      response.Properties.ReplyTo.should == "joe@example.com"
    end

    should "send smart email to one recipient" do
      stub_post(@auth, "transactional/smartemail/#{@smart_email_id}/send", "tx_send_single.json")
      email = {
        "To" => "Bob Sacamano <bob@example.com>",
        "Data" => {
          "anEmailVariable" => 'foo',
          "anotherEmailVariable" => 'bar'
        }
      }
      response = CreateSend::Transactional::SmartEmail.new(@auth, @smart_email_id).send(email)
      response.length.should == 1
      response[0].MessageID.should == "0cfe150d-d507-11e4-84a7-c31e5b59881d"
      response[0].Recipient.should == "\"Bob Sacamano\" <bob@example.com>"
      response[0].Status.should == "Received"
    end

    should "send smart email to multiple recipients with all the options" do
      stub_post(@auth, "transactional/smartemail/#{@smart_email_id}/send", "tx_send_multiple.json")
      email = {
        "To" => [
          "Bob Sacamano <bob@example.com>",
          "Newman <newman@example.com>",
        ],
        "CC" => [],
        "BCC" => [],
        "Data" => {
          "anEmailVariable" => 'foo',
          "anotherEmailVariable" => 'bar'
        },
        "Attachments" => [
          "Name" => "filename.gif",
          "Type" => "image/gif",
          "Content" => "R0lGODlhIAAgAKIAAP8AAJmZADNmAMzMAP//AAAAAP///wAAACH/C1hNUCBEYXRhWE1QPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNS42LWMwMTQgNzkuMTU2Nzk3LCAyMDE0LzA4LzIwLTA5OjUzOjAyICAgICAgICAiPiA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtbG5zOnhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIiB4bWxuczpzdFJlZj0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlUmVmIyIgeG1wOkNyZWF0b3JUb29sPSJBZG9iZSBQaG90b3Nob3AgQ0MgMjAxNCAoTWFjaW50b3NoKSIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDowNzZGOUNGOUVDRDIxMUU0ODM2RjhGMjNCMTcxN0I2RiIgeG1wTU06RG9jdW1lbnRJRD0ieG1wLmRpZDowNzZGOUNGQUVDRDIxMUU0ODM2RjhGMjNCMTcxN0I2RiI+IDx4bXBNTTpEZXJpdmVkRnJvbSBzdFJlZjppbnN0YW5jZUlEPSJ4bXAuaWlkOjA3NkY5Q0Y3RUNEMjExRTQ4MzZGOEYyM0IxNzE3QjZGIiBzdFJlZjpkb2N1bWVudElEPSJ4bXAuZGlkOjA3NkY5Q0Y4RUNEMjExRTQ4MzZGOEYyM0IxNzE3QjZGIi8+IDwvcmRmOkRlc2NyaXB0aW9uPiA8L3JkZjpSREY+IDwveDp4bXBtZXRhPiA8P3hwYWNrZXQgZW5kPSJyIj8+Af/+/fz7+vn49/b19PPy8fDv7u3s6+rp6Ofm5eTj4uHg397d3Nva2djX1tXU09LR0M/OzczLysnIx8bFxMPCwcC/vr28u7q5uLe2tbSzsrGwr66trKuqqainpqWko6KhoJ+enZybmpmYl5aVlJOSkZCPjo2Mi4qJiIeGhYSDgoGAf359fHt6eXh3dnV0c3JxcG9ubWxramloZ2ZlZGNiYWBfXl1cW1pZWFdWVVRTUlFQT05NTEtKSUhHRkVEQ0JBQD8+PTw7Ojk4NzY1NDMyMTAvLi0sKyopKCcmJSQjIiEgHx4dHBsaGRgXFhUUExIREA8ODQwLCgkIBwYFBAMCAQAAIfkEAAAAAAAsAAAAACAAIAAAA5loutz+MKpSpIWU3r1KCBW3eYQmWgWhmiemEgPbNqk6xDOd1XGYV77UzTfbTWC4nAHYQRKLu1VSuXxlpsodAFDAZrfcIbXDFXqhNacoQ3vZpuxHSJZ2zufyTqcunugdd00vQ0F4chQCAgYCaTcxiYuMMhGJFG89kYpFl5MzkoRPnpJskFSaDqctRoBxHEQsdGs0f7Qjq3utDwkAOw=="
        ],
        "AddRecipientsToListID" => true
      }
      response = CreateSend::Transactional::SmartEmail.new(@auth, @smart_email_id).send(email)
      response.length.should == 2
      response[1].MessageID.should == "0cfe150d-d507-11e4-b579-a64eb0d9c74d"
      response[1].Recipient.should == "\"Newman\" <newman@example.com>"
      response[1].Status.should == "Received"
    end

  end
end


