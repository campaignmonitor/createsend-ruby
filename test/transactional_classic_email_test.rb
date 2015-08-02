require File.dirname(__FILE__) + '/helper'

class TransactionalClassicEmailTest < Test::Unit::TestCase
  multiple_contexts "authenticated_using_oauth_context", "authenticated_using_api_key_context" do
    setup do
      @client_id = "87y8d7qyw8d7yq8w7ydwqwd"
      @email = CreateSend::Transactional::ClassicEmail.new @auth, @client_id
    end

    should "send classic email to one recipient" do
      stub_post(@auth, "transactional/classicemail/send", "tx_send_single.json")
      email = {
        "From"       => "George <george@example.com>",
        "Subject"    => "Thanks for signing up to Vandelay Industries",
        "To"         => "Bob Sacamano <bob@example.com>",
        "HTML"       => "<h1>Welcome</h1><a href='http://example.com/'>Click here</a>",
        "Group" => 'Ruby test group'
      }
      response = CreateSend::Transactional::ClassicEmail.new(@auth).send(email)
      response.length.should == 1
      response[0].Recipient.should == "\"Bob Sacamano\" <bob@example.com>"
    end

    should "send classic email to with all the options" do
      stub_post(@auth, "transactional/classicemail/send", "tx_send_multiple.json")
      email = {
        "From" => "T-Bone <tbone@example.com>",
        "ReplyTo" => "george@example.com",
        "Subject" => "Thanks for signing up to Vandelay Industries",
        "To" => [
          "Bob Sacamano <bob@example.com>",
          "Newman <newman@example.com>",
        ],
        "CC" => [],
        "BCC" => [],
        "HTML" => "<h1>Welcome</h1><a href='http://example.com/'>Click here</a>",
        "Text" => "Instead of using the auto-generated text from the HTML, you can supply your own.",
        "Attachments" => [
          "Name" => "filename.gif",
          "Type" => "image/gif",
          "Content" => "R0lGODlhIAAgAKIAAP8AAJmZADNmAMzMAP//AAAAAP///wAAACH/C1hNUCBEYXRhWE1QPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNS42LWMwMTQgNzkuMTU2Nzk3LCAyMDE0LzA4LzIwLTA5OjUzOjAyICAgICAgICAiPiA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtbG5zOnhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIiB4bWxuczpzdFJlZj0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlUmVmIyIgeG1wOkNyZWF0b3JUb29sPSJBZG9iZSBQaG90b3Nob3AgQ0MgMjAxNCAoTWFjaW50b3NoKSIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDowNzZGOUNGOUVDRDIxMUU0ODM2RjhGMjNCMTcxN0I2RiIgeG1wTU06RG9jdW1lbnRJRD0ieG1wLmRpZDowNzZGOUNGQUVDRDIxMUU0ODM2RjhGMjNCMTcxN0I2RiI+IDx4bXBNTTpEZXJpdmVkRnJvbSBzdFJlZjppbnN0YW5jZUlEPSJ4bXAuaWlkOjA3NkY5Q0Y3RUNEMjExRTQ4MzZGOEYyM0IxNzE3QjZGIiBzdFJlZjpkb2N1bWVudElEPSJ4bXAuZGlkOjA3NkY5Q0Y4RUNEMjExRTQ4MzZGOEYyM0IxNzE3QjZGIi8+IDwvcmRmOkRlc2NyaXB0aW9uPiA8L3JkZjpSREY+IDwveDp4bXBtZXRhPiA8P3hwYWNrZXQgZW5kPSJyIj8+Af/+/fz7+vn49/b19PPy8fDv7u3s6+rp6Ofm5eTj4uHg397d3Nva2djX1tXU09LR0M/OzczLysnIx8bFxMPCwcC/vr28u7q5uLe2tbSzsrGwr66trKuqqainpqWko6KhoJ+enZybmpmYl5aVlJOSkZCPjo2Mi4qJiIeGhYSDgoGAf359fHt6eXh3dnV0c3JxcG9ubWxramloZ2ZlZGNiYWBfXl1cW1pZWFdWVVRTUlFQT05NTEtKSUhHRkVEQ0JBQD8+PTw7Ojk4NzY1NDMyMTAvLi0sKyopKCcmJSQjIiEgHx4dHBsaGRgXFhUUExIREA8ODQwLCgkIBwYFBAMCAQAAIfkEAAAAAAAsAAAAACAAIAAAA5loutz+MKpSpIWU3r1KCBW3eYQmWgWhmiemEgPbNqk6xDOd1XGYV77UzTfbTWC4nAHYQRKLu1VSuXxlpsodAFDAZrfcIbXDFXqhNacoQ3vZpuxHSJZ2zufyTqcunugdd00vQ0F4chQCAgYCaTcxiYuMMhGJFG89kYpFl5MzkoRPnpJskFSaDqctRoBxHEQsdGs0f7Qjq3utDwkAOw=="
        ],
        "Group" => "Ruby test group",
        "AddRecipientsToListID" => "6d0366fcee146ab9bdaf3247446bbfdd"
      }
      response = CreateSend::Transactional::ClassicEmail.new(@auth).send(email)
      response.length.should == 2
      response[1].Recipient.should == "\"Newman\" <newman@example.com>"
    end

    should "get the list of classic groups" do
      stub_get(@auth, "transactional/classicemail/groups", "tx_classicemail_groups.json")
      response = CreateSend::Transactional::ClassicEmail.new(@auth).groups
      response.length.should == 3
      response[0].Group.should == "Password Reset"
    end

  end
end

