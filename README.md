# createsend

A ruby wrapper for the createsend API v3.

## Installation

    sudo gem install createsend

## Example

Retrieve a list of all your clients.

    require 'createsend'

    CreateSend.api_key 'your_api_key'

    cs = CreateSend.new
    clients = cs.clients
    
    clients.each do |c|
      puts "#{c.ClientID}: #{c.Name}"
    end

Results in:
    
    4a397ccaaa55eb4e6aa1221e1e2d7122: Client One
    a206def0582eec7dae47d937a4109cb2: Client Two

If the createsend API returns an error, an exception will be thrown. For example, if you attempt to create a campaign and enter empty values for subject etc:

    begin
      cl = Client.new "4a397ccaaa55eb4e6aa1221e1e2d7122"
      id = Campaign.create cl.client_id, "", "", "", "", "", "", "", [], []
      puts "New campaign ID: #{id}"
      rescue BadRequest => br
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
