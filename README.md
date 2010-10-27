# createsend

A wrapper for the createsend API v3.

## Installation

    sudo gem install createsend

## Example

    require 'createsend'

    CreateSend.api_key 'your_api_key'

    cs = CreateSend.new
    cs.clients
    => [<#Hashie::Mash ClientID="4a397ccaaa55eb4e6aa1221e1e2d7122" Name="Client One">, <#Hashie::Mash ClientID="a206def0582eec7dae47d937a4109cb2" Name="Client Two">
