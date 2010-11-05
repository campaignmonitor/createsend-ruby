# createsend

A ruby wrapper for the createsend API v3.

## Installation

    sudo gem install createsend

## Example

    require 'createsend'

    CreateSend.api_key 'your_api_key'

    cs = CreateSend.new
    clients = cs.clients
    clients.each do |c|
      puts "#{c.ClientID}: #{c.Name}"
    end
    
    4a397ccaaa55eb4e6aa1221e1e2d7122: Client One
    a206def0582eec7dae47d937a4109cb2: Client Two
