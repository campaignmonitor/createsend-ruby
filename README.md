# createsend

A ruby library which implements the complete functionality of v3 of the CreateSend API.

## Installation

    gem install createsend

## Examples

### Basic usage
Retrieve a list of all your clients.

    require 'createsend'

    CreateSend.api_key 'your_api_key'

    cs = CreateSend::CreateSend.new
    clients = cs.clients
    
    clients.each do |c|
      puts "#{c.ClientID}: #{c.Name}"
    end

Results in:
    
    4a397ccaaa55eb4e6aa1221e1e2d7122: Client One
    a206def0582eec7dae47d937a4109cb2: Client Two

### Handling errors
If the createsend API returns an error, an exception will be thrown. For example, if you attempt to create a campaign and enter empty values for subject etc:

    require 'createsend'

    CreateSend.api_key 'your_api_key'

    begin
      cl = CreateSend::Client.new "4a397ccaaa55eb4e6aa1221e1e2d7122"
      id = CreateSend::Campaign.create cl.client_id, "", "", "", "", "", "", "", [], []
      puts "New campaign ID: #{id}"
      rescue CreateSend::BadRequest => br
        puts "Bad request error: #{br}"
        puts "Error Code:    #{br.data.Code}"
        puts "Error Message: #{br.data.Message}"
      rescue Exception => e
        puts "Error: #{e}"
    end

Results in:

    Bad request error: The CreateSend API responded with the following error - 304: Campaign Subject Required
    Error Code:    304
    Error Message: Campaign Subject Required

### Expected input and output
The best way of finding out the expected input and output of a particular method in a particular class is to use the unit tests as a reference.

For example, if you wanted to find out how to call the CreateSend::Subscriber.add method, you would look at the file test/subscriber_test.rb

    should "add a subscriber with custom fields" do
      stub_post(@api_key, "subscribers/#{@list_id}.json", "add_subscriber.json")
      custom_fields = [ { :Key => 'website', :Value => 'http://example.com/' } ]
      email_address = CreateSend::Subscriber.add @list_id, "subscriber@example.com", "Subscriber", custom_fields, true
      email_address.should == "subscriber@example.com"
    end
